import uuid

def idGenrate():
    id = str(uuid.uuid4()).split("-")[0].upper()
    return id



def projectIdGenrator():
    id = str(uuid.uuid4()).split("-")[4].upper()
    return id


def issuesIdGenrator():
    id = str(uuid.uuid4()).split("-")[1]
    return id

def commentIdGenrator():
    id = str(uuid.uuid4()).split("-")[2]
    return id
