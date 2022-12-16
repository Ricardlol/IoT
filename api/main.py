import asyncio
from utils.connection_manager import ConnectionManager
from utils.db_manager import DbManager
import uvicorn
from fastapi import Depends, FastAPI, HTTPException, WebSocket, WebSocketDisconnect, status

from models.models import *


import logging
from dependencies import *
from routers import users, auth, sensors
from typing import List
import time

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
            detail="Incorrect phone number. Maybe user does not exist.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.phone_number}, expires_delta=access_token_expires
    )

    utils.users.refresh_token(db, user.phone_number, access_token)
    return {"access_token": access_token, "token_type": "bearer"}

def calculate_data(sensor_values: List[schemas.Sensor]):
    """Calculate data for all sensors"""
    # for sensor in sensor_values:
    #     print(sensor.data)

    return sum([sensor.data for sensor in sensor_values])

def get_sensor_value(sensor_type: str, sensor_values: List[schemas.Sensor]):
    for sensor in sensor_values:
        if sensor.sensor_type == sensor_type:
            return sensor.data 

manager = ConnectionManager()

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str, db: Session = Depends(get_db)):
    
    # if (path_to_upload.isNotEmpty)
    # {
    #   _channel = WebSocketChannel.connect(
    #     Uri.parse('wss://${Api.instance.API_BASE_URL}/ws/{$path_to_upload}'),
    #   );
    # }
    
    await manager.connect(websocket)
    
    print("Connected")
    manager.active_users.append(utils.users.get_user_by_id(db, client_id, True))
    message_sent = False

    try:
        while True:
            # data = await websocket.receive_text()
            # # print('WEBSOCKET: ' + data)
            # if len(data) > 0:
            #     print('WEBSOCKET: ' + data)
            print("Waiting for data")
            if len(manager.active_users) > 0:
                for user in manager.active_users:
                    db = SessionLocal()

                    user_db = utils.users.get_user_by_id(db, user.id, True)
                    sensor_values = user_db.sensors
                    print(sensor_values)

                    glucose_value = get_sensor_value("sugar_in_blood", sensor_values)
                    print(glucose_value)
                    heart_rate_value = get_sensor_value("heart_rate", sensor_values)
                    print(heart_rate_value)
                    pressure_value = get_sensor_value("blood_presure", sensor_values)
                    print(pressure_value)
                    oxygen_in_blood_value = get_sensor_value("oxygen_in_blood", sensor_values)
                    print(oxygen_in_blood_value)

                    if glucose_value != 0 and heart_rate_value != 0 and pressure_value != 0 and oxygen_in_blood_value != 0:
                        # await manager.send_personal_message(message=str(data), websocket=websocket)
                        if glucose_value > 85 and message_sent == False:
                            message = "You need to take insulin||https://cdn-icons-png.flaticon.com/512/6192/6192146.png"
                            await manager.send_personal_message(message=message, websocket=websocket)
                            # message_sent = True
                            # modify sensor value to 0
                            # for sensor in sensor_values:
                            #     sensor.data = 0
                            #     db.commit()
                            #     db.refresh(sensor)

                        if heart_rate_value < 70 and message_sent == False:
                            message = "Take a look at your heart rate!||https://cdn-icons-png.flaticon.com/512/865/865969.png"
                            await manager.send_personal_message(message=message, websocket=websocket)

                        if pressure_value > 120 and message_sent == False:
                            message = "Take a look at your blood pressure!||https://cdn-icons-png.flaticon.com/512/5015/5015609.png"
                            await manager.send_personal_message(message=message, websocket=websocket)

                        if oxygen_in_blood_value < 100 and message_sent == False:
                            message = "Take a look at your oxygen in blood values!||https://icons.veryicon.com/png/o/healthcate-medical/medical-and-health-industry-icon-library/blood-oxygen-3.png"
                            await manager.send_personal_message(message=message, websocket=websocket)
                    
                    message_sent = True

                    # every 10 seconds, allow to send message again
                    await asyncio.sleep(20)
                    message_sent = False
                    
                    # await manager.broadcast(message=str(data))
                    await asyncio.sleep(1)
                

            

    except WebSocketDisconnect:
        manager.disconnect(websocket)
        # await manager.broadcast(f"Client #{path_str} left the chat")

if __name__ == "__main__":
    uvicorn.run(app, host='127.0.0.1', port=8000)