from minio import Minio

MINIO_API_HOST = "http://localhost:9090"
MINIO_CLIENT = Minio("localhost:9000", access_key="TJEdi0O88Oqul2dbfpVr", secret_key="0YnihZYZO0SCZMXW5UD674geA4Q2DuoTfmPBmwiL", secure=False)

def main():
    found = MINIO_CLIENT.bucket_exists("ppc-in-im-scheduling-models")
    
    MINIO_CLIENT.fput_object("ppc-in-im-scheduling-models", "NrZwei", "C:/Users/sapel/minio/test2.py",)
    print("It is successfully uploaded to bucket")

if __name__ == "__main__":
    main()