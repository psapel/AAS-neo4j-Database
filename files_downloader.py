from minio import Minio
from minio.error import S3Error
import os

MINIO_API_HOST = "http://localhost:9090"
MINIO_CLIENT = Minio("localhost:9000", access_key="khZYtQV3U4mITypD4TV7", secret_key="eWkeqs9kUFB1c2XbIw43w3nR2XSoMySRZy2mvtCj", secure=False)

def download_file(bucket_name, object_name, destination_folder):
    try:
        os.makedirs(destination_folder, exist_ok=True)
        file_path = os.path.join(destination_folder, object_name)
        MINIO_CLIENT.fget_object(bucket_name, object_name, file_path)
        print(f"File '{object_name}' successfully downloaded to '{destination_folder}'")
    except S3Error as e:
        print(f"Error downloading file from MinIO: {e}")

def main():
    bucket_name = "query-bucket"
    destination_folder = "queries"

    objects = MINIO_CLIENT.list_objects(bucket_name)
    for obj in objects:
        object_name = obj.object_name
        if object_name.endswith(".py"):  
            download_file(bucket_name, object_name, destination_folder)

if __name__ == "__main__":
    main()
