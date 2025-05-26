""" Module with SQL utils """

from typing import List

def generate_copy_sql(
        table_name: str,
        db_local_data_file: str,
        table_columns: List[str] = None,
        file_format: str = 'csv') -> List[str]:
    return [
        f"truncate table {table_name};",
        (f"copy {table_name}" +
         (f"({', '.join(table_columns)})" if table_columns else '') +
         f" from '{db_local_data_file}'" +
         (f" with (format {file_format}, header true);" if file_format and file_format.lower() == 'csv' else '') +
         ";"
        ),
        f"analyze {table_name};",
    ]