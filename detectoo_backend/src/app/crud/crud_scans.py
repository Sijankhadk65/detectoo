from fastcrud import FastCRUD

from ..models.scan import Scan
from ..schemas.scan import ScanCreateInternal, ScanDelete, ScanRead, ScanUpdate, ScanUpdateInternal

CRUDScan = FastCRUD[Scan, ScanCreateInternal, ScanUpdate, ScanUpdateInternal, ScanDelete, ScanRead]
crud_scans = CRUDScan(Scan)
