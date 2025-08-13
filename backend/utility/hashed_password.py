from passlib.context import CryptContext

pwd_crypt = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_crypt.hash(password)

def verify_password(plan_password: str, hash_password: str) -> bool:
    return pwd_crypt.verify(plan_password, hash_password)
