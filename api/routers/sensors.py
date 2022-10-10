import os
from typing import List

from fastapi import APIRouter, Depends, HTTPException


from dependencies import *
from fastapi.responses import PlainTextResponse

import utils.sensors

router = APIRouter(
    prefix="/sensors",
    tags=["sensors"],
    dependencies=[Depends(get_db), Depends(get_current_active_user)],
    responses={404: {"description": "Not found"}},
)

@router.get("/", response_model=list[schemas.Sensor])
def read_sensors(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    sensors_list = utils.sensors.get_sensors(db, skip=skip, limit=limit)
    return sensors_list

@router.post("/", response_model=schemas.Sensor)
def create_sensor(sensor: schemas.Sensor, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_sensor = utils.sensors.get_sensor(db=db, sensor_id=sensor.id)
    if db_sensor:
        raise HTTPException(status_code=400, detail="Sensor already created")

    return  utils.sensors.create_sensor(db=db, sensor=sensor, current_user=current_user, stop_id=sensor.stop_id)

@router.put("/{id}", response_model=schemas.Sensor)
def update_sensor(sensor: schemas.Sensor, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_sensor = utils.sensors.get_sensor(db=db, sensor_id=sensor.id)

    if not db_sensor:
        raise HTTPException(status_code=404, detail="Sensor with id {0} not found".format(str(id)))

    return  utils.sensors.update_sensor(db=db, sensor=sensor, db_sensor = db_sensor)

@router.delete("/{id}", response_model=schemas.Sensor)
def delete_sensor(id: str, db: Session = Depends(get_db), current_user: schemas.User = Depends(get_current_active_user)):
    db_sensor = utils.sensors.get_sensor(db=db, sensor_id=id)

    if not db_sensor:
        raise HTTPException(status_code=404, detail="Sensor with id {0} not found".format(str(id)))

    return  utils.sensors.delete_sensor(db=db, sensor_id=id)

