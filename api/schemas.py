from typing import List, Union

from pydantic import BaseModel

import datetime


class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    phone_number: Union[str, None] = None

class BaseSensorSchema(BaseModel):
    """Base schema for all schemas"""
    id: str
    sensor_type: str
    name: str
    data: float
    user_id : str
    unit_of_measurement: str

    class Config:
        orm_mode = True

class Sensor(BaseSensorSchema):
    """Schema for sensor"""

class UserCreate(BaseModel):
    phone_number: str
    full_name: str
    age: int
    gender: str

class User(BaseModel):
    id: str
    age: int
    gender: str
    phone_number: str
    full_name: str
    avatar_url: str
    disabled: bool 
    creation_date: datetime.datetime
    sensors: Union[List[Sensor], None] = None  

class UserInDB(User):
    # id: str
    hashed_password: str
    creation_date: datetime.datetime
    token:  Union[str, None] = None

    class Config:
        orm_mode = True




