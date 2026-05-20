import json
from kafka import KafkaConsumer

KAFKA_BOOTSTRAP_SERVERS = ['localhost:9092']
KAFKA_TOPIC = 'ishqa11_events'

def main():
    print("📥 Initializing Ishqa11 Secure Consumer Layer...")
    
    try:
        consumer = KafkaConsumer(
            KAFKA_TOPIC,
            bootstrap_servers=KAFKA_BOOTSTRAP_SERVERS,
            auto_offset_reset='latest',
            enable_auto_commit=True,
            group_id='ishqa11_analytics_group',
            value_deserializer=lambda x: json.loads(x.decode('utf-8'))
        )
        
        print(f"📡 Connected to topic: '{KAFKA_TOPIC}'... Awaiting streaming payloads.")
        
        for message in consumer:
            payload = message.value
            # Production Log Pattern
            print(f"📥 Received Payloads: {payload['event_id']} | Device: {payload['device']} | Processing Zone: Bronze")
            
            # NOTE: Yahan se direct AWS Boto3 payload downstream push hoga local chunking ke baad
            
    except Exception as e:
        print(f"❌ Critical Infrastructure Failure in Consumer: {str(e)}")

if __name__ == "__main__":
    main()