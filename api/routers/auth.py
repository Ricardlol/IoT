import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Request

from dependencies import *

import utils.users



router = APIRouter(
    prefix="/token",
    tags=["token"],
)

@router.post("/validate_token", response_model=schemas.UserInDB)
async def  validate_token(token: schemas.Token, db : Session = Depends(get_db)):
    user = utils.users.get_user_by_token(db, token=token.access_token)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token is invalid",
            headers={"WWW-Authenticate": "Bearer"},
        )

    print("User found")
    print(user)
    
    return  user


# ONLY ALLOW PNG and JPG FILES TO BE UPLOADED FOR NOW
# IMPORTANT: first we register user and then we get the user id to upload the file

@router.post("/upload_profile_picture", response_model=schemas.UserInDB)
async def create_upload_file(request: Request, db: Session = Depends(get_db), uploaded_file: UploadFile = File(...)):    
    # get user_id from request fields 
    user_id = request.headers.get("user_id")

    print("Searching for user {}".format(user_id))

    user = utils.users.get_user_by_id(db, user_id=user_id, return_db_user=True)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with id {} not found".format(user_id),
        )
    
    # check if uploaded file is a png file
    if uploaded_file.content_type != "image/png" and uploaded_file.content_type != "image/jpeg":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PNG and JPG files are allowed",
        )
    
    image_uri = "https://picsum.photos/50/50?random=1"

    user.avatar_url = image_uri
    user.save(db)

    return user

@router.post("/register", response_model=schemas.UserInDB)
async def register_user(form_data: schemas.UserCreate, db : Session = Depends(get_db)):
    user = utils.users.get_user_by_phone_number(db, form_data.phone_number)
    
    if user:
        raise HTTPException(status_code=400, detail="User already exists")

    hashed_password = get_password_hash(form_data.phone_number)
    user = utils.users.create_user(db, form_data, hashed_password)
    
    print("User created")
    print(user)
    for sensor in user.sensors:
        print(sensor.__dict__)

    return user

@router.post("/logout", response_model=schemas.Token)
async def logout_user(current_user: schemas.User = Depends(get_current_active_user), db : Session = Depends(get_db)):
    user = utils.users.get_user_by_phone_number(db, current_user.phone_number)
    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")
    
    utils.users.refresh_token_with_user(db, user, None)
    return user

@router.post("/refresh", response_model=schemas.Token)
async def refresh_token(current_user: schemas.User = Depends(get_current_active_user), db : Session = Depends(get_db)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": current_user.phone_number}, expires_delta=access_token_expires
    )

    utils.users.refresh_token(db, current_user.phone_number, access_token)

    return {"access_token": access_token, "token_type": "bearer"}

