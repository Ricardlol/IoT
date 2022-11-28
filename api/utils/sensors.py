from fastapi import HTTPException
from sqlalchemy.orm import Session

from models import models

import schemas
import uuid

def get_sensor(db: Session, sensor_id: int):
    return db.query(models.Sensor).filter(models.Sensor.id == sensor_id).first()

def get_sensors(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Sensor).offset(skip).limit(limit).all()

def get_sensor_by_name(db: Session, name: str):
    return db.query(models.Sensor).filter(models.Sensor.name == name).first()

def create_sensor(db: Session, sensor: schemas.Sensor, current_user: schemas.User, stop_id: str):
    # current_date = datetime.datetime.now()

    # first information is filled in ProcessFile function
    db_sensor = models.Sensor(
        id = sensor.id,
        sensor_type = sensor.sensor_type,
        name = sensor.name,
        data = sensor.data,
    )
    
    db_sensor.save(db)

    return db_sensor

def delete_sensor(db: Session, sensor_id: int):
    db_sensor = get_sensor(db, sensor_id)
    
    if db_sensor:
        db.delete(db_sensor)
        db.commit()
        return db_sensor
    else:
        raise HTTPException(status_code=404, detail="Sensor with id {0} not found".format(str(sensor_id)))

def update_sensor(db: Session, sensor: schemas.Sensor, db_sensor: models.Sensor):
    db_sensor.id = sensor.id
    db_sensor.sensor_type = sensor.sensor_type
    db_sensor.name = sensor.name
    db_sensor.data = sensor.data
    db_sensor.save(db)

    return db_sensor

def get_platform_sensors(user_db: models.User):
    sensors = []
    sensors.append(schemas.Sensor(id=str(uuid.uuid4()), unit_of_measurement="mg/dl", sensor_type="sugar_in_blood", name="Glucose Reader", data=0, user_id=user_db.id))
    sensors.append(schemas.Sensor(id=str(uuid.uuid4()), unit_of_measurement="mm/Hg", sensor_type="blood_presure", name="Blood Presure", data=0, user_id=user_db.id))
    sensors.append(schemas.Sensor(id=str(uuid.uuid4()), unit_of_measurement="HRV", sensor_type="heart_rate", name="Heart Rate", data=0, user_id=user_db.id))
    sensors.append(schemas.Sensor(id=str(uuid.uuid4()), unit_of_measurement="HRV", sensor_type="oxygen_in_blood", name="Oxygen in Blood", data=0, user_id=user_db.id))

    return sensors