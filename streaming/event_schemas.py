from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Optional

class Ishqa11EventSchema(BaseModel):
    """Strict Enterprise Schema Enforcement Pattern to prevent Data Lake pollution"""
    event_id: str = Field(..., min_length=6, description="Unique telemetry identifier")
    user_id: str = Field(..., description="Global user reference map")
    event_type: str = Field(..., description="Transactional matrix status")
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    amount: float = Field(default=0.0, ge=0.0, description="Financial volume metric")
    device: str = Field(..., description="Client ingestion platform channel")

    @field_validator('event_type')
    @classmethod
    def validate_event_type(cls, v: str) -> str:
        allowed = ['CLICK', 'CART_ADD', 'CHECKOUT_START', 'PURCHASE_SUCCESS']
        if v.upper() not in allowed:
            raise ValueError(f"🚨 Invalid Event Type Pipeline Attack: {v}")
        return v.upper()