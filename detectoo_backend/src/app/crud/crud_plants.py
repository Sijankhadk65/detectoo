from fastcrud import FastCRUD

from ..models.plant import Plant
from ..schemas.plant import PlantCreateInternal, PlantDelete, PlantRead, PlantUpdate, PlantUpdateInternal

CRUDPlant = FastCRUD[Plant, PlantCreateInternal, PlantUpdate, PlantUpdateInternal, PlantDelete, PlantRead]
crud_plants = CRUDPlant(Plant)
