from utils.connection_manager import ConnectionManager
from utils.db_manager import DbManager
import uvicorn
from fastapi import Depends, FastAPI, HTTPException, WebSocket, WebSocketDisconnect, status

from models.models import *


import logging
from dependencies import *
from routers import users, auth, sensors


dir_path = 'api.log'
logging.basicConfig(filename=dir_path, filemode='w', format='%(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# add the handler to the root logger
logging.getLogger('').addHandler(console)
logging.info("Log file will be saved to temporary path: {0}".format(dir_path))

Base.metadata.create_all(bind=engine)


app = FastAPI(debug = True)
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(sensors.router)

db_manager = DbManager(db_session=SessionLocal())

@app.post("/token", response_model=schemas.Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db : Session = Depends(get_db)):
    user = authenticate_user(db, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.phone_number}, expires_delta=access_token_expires
    )

    utils.users.refresh_token(db, user.phone_number, access_token)
    return {"access_token": access_token, "token_type": "bearer"}

manager = ConnectionManager()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str,  path_str: str , db: Session = Depends(get_db)):
    
    # if (path_to_upload.isNotEmpty)
    # {
    #   _channel = WebSocketChannel.connect(
    #     Uri.parse('wss://${Api.instance.API_BASE_URL}/ws/{$path_to_upload}'),
    #   );
    # }
    
    await manager.connect(websocket)
    
    print("Connected")

    await manager.broadcast(client_id + " connected")
    await manager.broadcast(client_id + " is watchdoging for path " + path_str)

    try:
        while True:
            data = await websocket.receive_text()
            # print('WEBSOCKET: ' + data)
            if len(data) > 0:
                print('WEBSOCKET: ' + data)

    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"Client #{path_str} left the chat")

if __name__ == "__main__":
    uvicorn.run(app, host='127.0.0.1', port=8000, debug=True)