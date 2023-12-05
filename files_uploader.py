from minio import Minio
from minio.error import S3Error
import os

MINIO_API_HOST = "http://localhost:9090"
MINIO_CLIENT = Minio("localhost:9000", access_key="khZYtQV3U4mITypD4TV7", secret_key="eWkeqs9kUFB1c2XbIw43w3nR2XSoMySRZy2mvtCj", secure=False)

def upload_file(file_path, bucket_name, object_name):
    try:
        found = MINIO_CLIENT.bucket_exists(bucket_name)
        if not found:
            MINIO_CLIENT.make_bucket(bucket_name)
        
        MINIO_CLIENT.fput_object(bucket_name, object_name, file_path)
        print(f"File '{file_path}' successfully uploaded to bucket '{bucket_name}' as '{object_name}'")
    except S3Error as e:
        print(f"Error uploading file to MinIO: {e}")

def main():
    folder_path = "queries"
    bucket_name = "query-bucket"

    for file_name in os.listdir(folder_path):
        if file_name.endswith(".py"): 
            file_path = os.path.join(folder_path, file_name)
            object_name = file_name
            upload_file(file_path, bucket_name, object_name)

if __name__ == "__main__":
    main()
