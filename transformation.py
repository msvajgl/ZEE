import xml.etree.cElementTree as ET
import json
from datetime import datetime

def get_text(element):
    if element is None or element.text is None or element.text.strip() == "":
        return None
    return element.text.strip()

def parse_date(date_str):
    try:
        return datetime.strptime(date_str, "%Y%m%d").strftime("%Y-%m-%dT00:00:00") if date_str else None
    except (ValueError, TypeError):
        return None

sample_string = input
sample_string_bytes = sample_string.encode("UTF-8")
root = ET.fromstring(sample_string_bytes)
namespace = {"ns": "http://schema.infor.com/InforOAGIS/2"}

fields = [
    "Company", "Division", "ItemNumber", "ProductName", "ItemDescription", "Status", "ItemType",
    "ItemGroup", "MakeBuyCode", "AccessControlObject", "BusinessArea", "ProductGroup", "BasicUoM",
    "AlternativeUoM", "HierachyLVL1", "HierachyLVL1Label", "HierachyLVL2", "HierachyLVL2Label",
    "HierachyLVL3", "HierachyLVL3Label", "Code", "ShelfLife", "Supplier", "SupplierName", "NetWeight",
    "GrossWeight", "Lenght", "Width", "Height", "ItemResponsibleID", "ItemResponsibleName",
    "RegistrationDate", "LastChangeDate", "ChangeByID", "ChangeByName"
]

# Extracting and cleaning values
data = {field: get_text(root.find(f".//ns:{field}", namespace)) for field in fields}

data["RegistrationDate"] = parse_date(data["RegistrationDate"])
data["LastChangeDate"] = parse_date(data["LastChangeDate"])

# Special block for repeated elements
aliases = [
    f"{get_text(alias.find('ns:AliasQualifier', namespace))}:{get_text(alias.find('ns:AliasNumber', namespace))}"
    for alias in root.findall(".//ns:Alias", namespace)
    if get_text(alias.find("ns:AliasQualifier", namespace)) and get_text(alias.find("ns:AliasNumber", namespace))
]
data["Aliases"] = ", ".join(aliases) if aliases else None

# Mapping to output structure
output_data = {
    "m3_id": data["ItemNumber"],
    "active_status": data["Status"],
    "name": data["ProductName"],
    "internal_comp_num_c": data["Company"],
    "item_type_c": data["ItemType"],
    "item_group_c": data["ItemGroup"],
    "make_buy_c": data["MakeBuyCode"],
    "acc_control_c": data["AccessControlObject"],
    "area_c": data["BusinessArea"],
    "product_group_c": data["ProductGroup"],
    "unit_c": data["BasicUoM"],
    "alt_unit_c": data["AlternativeUoM"],
    "category_lvl1_id": data["HierachyLVL1"],
    "category_lvl2_id": data["HierachyLVL2"],
    "category_id": data["HierachyLVL3"],
    "expiration_time_c": data["ShelfLife"],
    "manufacturer_code_c": data["Supplier"],
    "manufacturer_name_c": data["SupplierName"],
    "part_num_c": data["Aliases"],
    "weight": data["NetWeight"],
    "weight_brutto_c": data["GrossWeight"],
    "lenght_c": data["Lenght"],
    "width_c": data["Width"],
    "height_c": data["Height"],
    "assigned_user_id": data["ItemResponsibleID"],
    "description": data["ItemDescription"],
    "date_entered": data["RegistrationDate"],
    "date_modified": data["LastChangeDate"],
    "modified_user_id": data["ChangeByID"]
}

output = json.dumps(output_data, ensure_ascii=False).encode('utf8')