from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import models

import schemas
import uuid
import datetime

import utils.sensors

def refresh_token_with_user(db: Session, user: models.User, token: str):
    user.token =  token
    db.add(user)
    db.commit()

    return user.token

def refresh_token(db: Session, phone_number: str, token: str):
    user = db.query(models.User).filter(models.User.phone_number == phone_number).first()
    user.token = token

    db.add(user)
    db.commit()

    return user.token



def get_user_by_token(db: Session, token: str, is_login: bool = False):
    dic = db.query(models.User).filter(models.User.token == token).first()
    
    if dic is None or  (dic.token == None and not is_login):
        return None

    return schemas.UserInDB(**dic.__dict__)

def get_user_sensors(db: Session, user_id: str):
    return db.query(models.Sensor).filter(models.Sensor.user_id == user_id).all()

def get_user_by_id(db: Session, user_id: str, return_db_user: bool = False):
    dic = db.query(models.User).filter(models.User.id == user_id).first()
    
    if dic is None:
        return None

    if return_db_user:
        return dic
        
    return schemas.UserInDB(**dic.__dict__)

def get_user_by_phone_number(db: Session, phone_number: str, is_login: bool = False):
    dic = db.query(models.User).filter(models.User.phone_number == phone_number).first()
    
    if dic is None or  (dic.token == None and not is_login):
        return None

    print(dic.sensors)

    return schemas.UserInDB(**dic.__dict__)

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


def create_user(db: Session, user: schemas.UserCreate, hashed_password: str):
    
    id = str(uuid.uuid4())
    current_date = datetime.datetime.now()

    db_user = models.User(id=id,
                            phone_number=user.phone_number,
                            full_name=user.full_name,
                            hashed_password=hashed_password,
                            disabled=False,
                            creation_date=current_date,
                            avatar_url= 'https://www.gravatar.com/avatar/',
                            token=None,
                            sensors = [])

    for sensor in utils.sensors.get_platform_sensors(db_user):
        # mix the user id with the sensor id to make it 36 characters long 
        stid = db_user.id[0:8] + sensor.id[8:]

        sensor_db = models.Sensor(id=stid,
                                            sensor_type=sensor.sensor_type,
                                            name=sensor.name,
                                            data=sensor.data,
                                            user_id=id)
        sensor_db.save(db)    
        db_user.sensors.append(sensor_db)

    db_user.save(db)

    return db_user

def delete_user(db: Session, user_id: str):
    db_user = get_user_by_id(db, user_id)
    if db_user:
        db.delete(db_user)
        db.commit()
        return db_user
    else:
        raise HTTPException(status_code=404, detail="User with id {0} not found".format(str(user_id)))

def update_user(db: Session, user: schemas.User, db_user: models.User):
    # update the user with the new data
    db_user.id = user.id
    db_user.phone_number = user.phone_number
    db_user.full_name = user.full_name
    db_user.disabled = user.disabled
    db_user.creation_date = user.creation_date

    db.add(db_user)
    db.commit()

    return db_user

def get_items(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


# def create_stop_item(db: Session, item: schemas.Wanderpi, user_id: int):
#     db_item = models.Item(**item.dict(), owner_id=user_id)
#     db.add(db_item)
#     db.commit()
#     db.refresh(db_item)
#     return db_item