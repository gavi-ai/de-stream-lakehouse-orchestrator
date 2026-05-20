import os
import io
import json
import logging
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

# Production Log Stream Configuration
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger("Ishqa11DataLakehouseEngine")

class S3BronzeDataSink:
    """Enterprise Cloud Storage Handler utilizing secure environment decoupling and automated data pooling."""
    
    def __init__(self):
        # Decouple configuration from code base using runtime environment registry
        self.bucket_name = os.getenv("AWS_BRONZE_BUCKET", "ishqa11-data-lake-storage")
        self.aws_region = os.getenv("AWS_REGION", "us-east-1")
        
        # Instantiate AWS SDK Client over localized implicit state bindings
        self.s3_client = boto3.client('s3', region_name=self.aws_region)
        logger.info(f"📊 Initialize AWS S3 Adapter connected to bucket system: {self.bucket_name}")

    def upload_stream_buffer(self, event_batch: list, extraction_layer: str = "v1"):
        """Converts incoming high-velocity runtime state matrices into micro-batched object streams on AWS Cloud."""
        if not event_batch:
            logger.warning("⚠️ Empty system buffer block received. Aborting upload thread.")
            return

        try:
            now = datetime.utcnow()
            
            # High-Performance Hive Partitioning Strategy optimized for Snowflake External Tables & Athena Pruning
            s3_path = (
                f"bronze/events/layer={extraction_layer}/"
                f"year={now.year}/month={now.strftime('%m')}/day={now.strftime('%d')}/"
                f"stream_block_{now.strftime('%H%M%S')}.json"
            )
            
            # Stringify streaming byte matrix using robust Line-Delimited JSON (JSON Lines format)
            buffer_data = "\n".join([json.dumps(e) for e in event_batch])
            
            logger.info(f"☁️ Compiling checkpoint segment to AWS Data Lake Target: {s3_path}")
            
            # Network Request Ingestion Thread
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=s3_path,
                Body=buffer_data.encode('utf-8'),
                ContentType='application/json'
            )
            logger.info("✅ System state synchronization finalized for checkpoint block.")
            
        except ClientError as ce:
            logger.error(f"❌ Structural AWS Service Failure during ingestion block: {str(ce)}")
            raise ce
        except Exception as e:
            logger.critical(f"🚨 Unhandled Runtime Crash inside Ingestion Gateway Layer: {str(e)}")
            raise e