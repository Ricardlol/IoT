from sqlalchemy.sql.schema import ForeignKey

import db
from sqlalchemy import Column, Boolean, String, Float, DateTime, Text, Date, Time, asc, func
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import relationship

from db import Base

from datetime import *

def datetime_parser(o):
    if isinstance(o, datetime):
        return o.__str__()

class BaseSensorModelSchema(object):
    @declared_attr
    def __tablename__(cls):
        return cls.__name__.lower()


    id = Column(String(36), primary_key=True)
    sensor_type = Column(String(255))
    name = Column(String(255))

    @declared_attr
    def user_id(cls):
        return Column(String(36), ForeignKey('users.id'))

    def save(self, db):
        db.add(self)
        db.commit()
        db.refresh(self)
        return self


class User(Base):
    __tablename__ = 'users'
    id = Column(String(36), primary_key=True)
    phone_number = Column(String(255))
    full_name = Column(String(255))
    hashed_password = Column(String(255))
    avatar_url = Column(String(255))
    disabled = Column(Boolean, default=False)
    creation_date = Column(DateTime, default=datetime.now)
    token = Column(String(255))
    sensors = relationship("Sensor")

    def save(self, db):
        db.add(self)
        db.commit()
        db.refresh(self)
        return self

    def __repr__(self):
        return f"<User {self.id}> {self.phone_number} {self.full_name} {self.avatar_url} {self.disabled} {self.creation_date} {self.token} {self.sensors}"
   

class Sensor(Base, BaseSensorModelSchema):
    __tablename__ = 'sensors'
    
    # data is a float value
    data = Column(Float)


