import json
import time
import random
from datetime import datetime
from kafka import KafkaProducer

# Configuration for Global Access
KAFKA_BOOTSTRAP_SERVERS = ['localhost:9092']
KAFKA_TOPIC = 'ishqa11_events'

def json_serializer(data):
    return json.dumps(data).encode('utf-8')

def generate_synthetic_event():
    """Engineered to simulate high-volume, unpredictable production loads"""
    event_types = ['click', 'cart_add', 'checkout_start', 'purchase_success']
    return {
        "event_id": f"evt_{random.randint(100000, 999999)}",
        "user_id": f"usr_{random.randint(1000, 9999)}",
        "event_type": random.choice(event_types),
        "timestamp": datetime.utcnow().isoformat(),
        "amount": round(random.uniform(10.0, 500.0), 2) if random.choice([True, False]) else 0.0,
        "device": random.choice(['iOS', 'Android', 'Web'])
    }

def main():
    print("⚡ Starting Ishqa11 Ingestion Engine (Producer)...")
    try:
        producer = KafkaProducer(
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            value_serializer=json_serializer,
            acks='all' # Hard fault-tolerance signal for international clients
        )
        
        while True:
            event = generate_synthetic_event()
            producer.send(KAFKA_TOPIC, value=event)
            print(f"🚀 Streamed Event: {event['event_id']} | Type: {event['event_type']}")
            time.sleep(random.uniform(0.1, 0.5)) # Micro-batch scale throttling
            
    except Exception as e:
        print(f"❌ Pipeline Failure in Producer: {str(e)}")

if __name__ == "__main__":
    main()