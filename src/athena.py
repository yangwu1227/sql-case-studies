import logging 
import sys
from re import match, IGNORECASE
from typing import Any, Dict, Sequence, Union, Optional

import boto3 
import pandas as pd
import awswrangler as wr

logger = logging.getLogger(name='athena')
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler(sys.stdout))

class AthenaQueryError(Exception):
    """
    Custom exception class for Athena query validation errors.
    """
    pass

class Athena(object):
    """
    A class to interact with AWS Athena.
    """
    def __init__(self, boto3_session: boto3.Session, s3_output: Optional[str] = None) -> None:
        """
        Initialize the Athena instance.

        Parameters
        ----------
        boto3_session: boto3.Session
            A boto3 session with the necessary permissions to interact with Athena.
        s3_output: Optional[str]
            The S3 path where the query results will be stored.

        Returns
        -------
        None

        Examples
        --------
        >>> from utils import create_session # See utils module
        >>> from athena import Athena
        >>> boto3_session = create_session(profile_name='profile_name', role_arn='arn:aws:iam::123456789012:role/role_name')
        >>> s3_output = 's3://bucket-name/path/to/query-results/'
        >>> athena = Athena(boto3_session=boto3_session, s3_output=s3_output)
        """
        self.boto3_session = boto3_session
        if s3_output:
            self.s3_output = s3_output  # This will trigger the setter verification
        else:
            self.s3_output = wr.athena.create_athena_bucket(boto3_session=self.boto3_session)

    @property
    def boto3_session(self) -> boto3.Session:
        return self._boto3_session
    
    @boto3_session.setter
    def boto3_session(self, boto3_session: boto3.Session) -> None:
        if not isinstance(boto3_session, boto3.Session):
            raise ValueError("boto3_session must be an instance of boto3.Session")
        self._boto3_session = boto3_session

    @property
    def s3_output(self) -> str:
        return self._s3_output
    
    @s3_output.setter
    def s3_output(self, s3_output: str) -> None:
        if not isinstance(s3_output, str) or s3_output.endswith("/"):
            raise ValueError("s3_output must be a valid S3 path not ending with a slash")
        if wr.s3.does_object_exist(path=s3_output, boto3_session=self.boto3_session):
            raise ValueError("s3_output must be a valid existing S3 path")
        self._s3_output = s3_output

    def __repr__(self) -> str:
        return f"Athena(boto3_session={self.boto3_session}, s3_output={self.s3_output})"

    def _check_valid_identifier(self, identifier: str):
        """
        Validate if the provided string is a valid SQL identifier.

        Parameters
        ----------
        identifier: str
            The identifier to validate.
        """
        # Check length constraints
        if not (1 <= len(identifier) <= 255):
            raise AthenaQueryError(f"Invalid identifier length: {identifier}")

        # Check if the identifier is a valid Python identifier
        if not identifier.isidentifier():
            raise AthenaQueryError(f"Invalid identifier: {identifier}")

    def _check_single_statement(self, query: str) -> None:
        """
        Check if the query contains exactly one SQL statement.

        Parameters
        ----------
        query: str
            The query to check.

        Returns
        -------
        None
        """
        if query.count(";") != 1:
            raise AthenaQueryError("Query must contain exactly one SQL statement with a single semicolon at the end")

    def _check_query(self, query: str, expected_start: Union[Sequence[str], str], error_message: str) -> None:
        """
        Check if the query starts with the expected SQL statement and contains exactly one semicolon.

        Parameters
        ----------
        query: str
            The query to check.
        expected_start: Union[Sequence[str], str]
            The expected start of the query either as a string or a list of strings.
        error_message: str
            The error message to raise if the query is invalid.

        Returns
        -------
        None
        """
        patterns = [expected_start] if isinstance(expected_start, str) else expected_start
        if not any(match(pattern, query.strip(), IGNORECASE) for pattern in patterns):
            raise AthenaQueryError(error_message)
    
    def _execute_query(self, database: str, query: str, **kwargs: Any) -> pd.DataFrame:
        """
        Execute a query in Athena.

        Parameters
        ----------
        database: str
            The name of the database to execute the query in.
        query: str
            The query to execute.
        **kwargs: Any
            Additional arguments passed to awswrangler.athena.start_query_execution.

        Returns
        -------
        pd.DataFrame
            The result of the query.
        """
        try:
            response = wr.athena.start_query_execution(
                sql=query, 
                database=database,
                s3_output=self.s3_output,
                boto3_session=self.boto3_session,
                **{k: v for k, v in kwargs.items() if k not in {'boto3_session', 's3_output'}}
            )
            logger.info(f"Query executed successfully")
            return response
        except Exception as e:
            logger.error(f"Error executing query: {e}")
            raise e

    def create_database(self, database: str, **kwargs: Dict[str, Any]) -> None:
        """
        Create a database in Athena.

        Parameters
        ----------
        database: str
            The name of the database to create.
        **kwargs: Dict[str, Any]
            Additional arguments passed to awswrangler.athena.start_query_execution.

        Returns
        -------
        None

        Examples
        --------
        >>> athena.create_database(database='my_database', wait=True) # See awswrangler.athena.start_query_execution for additional arguments
        """
        self._check_valid_identifier(database)
        query = f"CREATE DATABASE IF NOT EXISTS {database};"
        self._check_single_statement(query)
        self._execute_query(query=query, database=database, **kwargs)
        
    def drop_database(self, database: str, **kwargs: Dict[str, Any]) -> None:
        """
        Drop a database in Athena.

        Parameters
        ----------
        database: str
            The name of the database to drop.
        **kwargs: Dict[str, Any]
            Additional arguments passed to awswrangler.athena.start_query_execution.

        Returns
        -------
        None

        Examples
        --------
        >>> athena.drop_database(database='my_database', wait=True)
        """
        self._check_valid_identifier(database)
        query = f"DROP DATABASE IF EXISTS {database};"
        self._check_single_statement(query)
        self._execute_query(query=query, database=database, **kwargs)

    def create_table(self, database: str, query: str, **kwargs: Dict[str, Any]) -> None:
        """
        Create a table in Athena.

        Parameters
        ----------
        database: str
            The name of the database to create the table in.
        query: str
            The query to create the table.
        **kwargs: Dict[str, Any]
            Additional arguments passed to awswrangler.athena.start_query_execution.

        Returns
        -------
        None

        Examples
        --------
        >>> ddl = '''
        >>>       CREATE EXTERNAL TABLE IF NOT EXISTS my_database.my_table (
        >>>           id CHAR(1),
        >>>           date TIMESTAMP
        >>>       )
        >>>       STORED AS PARQUET
        >>>       LOCATION 's3://bucket-name/path/to/data/'
        >>>       TBLPROPERTIES ('parquet.compress'='SNAPPY');
        >>>       '''
        >>> athena.create_table(database='my_database', query=ddl, wait=True)
        """
        self._check_valid_identifier(database)
        self._check_single_statement(query)
        self._check_query(query, "CREATE EXTERNAL TABLE", "Query is invalid; please use CREATE EXTERNAL TABLE to create a table")
        self._execute_query(query=query, database=database, **kwargs)

    def drop_table(self, database: str, table: str, **kwargs: Dict[str, Any]) -> None:
        """
        Drop a table in Athena in the specified database.

        Parameters
        ----------
        database: str
            The name of the database to drop the table from.
        table: str
            The name of the table to drop.
        **kwargs: Dict[str, Any]
            Additional arguments passed to awswrangler.athena.start_query_execution.

        Returns
        -------
        None

        Examples
        --------
        >>> athena.drop_table(database='my_database', table='my_table', wait=True)
        """
        self._check_valid_identifier(database)
        query = f"DROP TABLE IF EXISTS {table};"
        self._check_single_statement(query)
        self._execute_query(query=query, database=database, **kwargs)

    def create_view(self, database: str, query: str, **kwargs: Dict[str, Any]) -> None:
        """
        Create a view in Athena.

        Parameters
        ----------
        query: str
            The query to create the view.
        **kwargs: Dict[str, Any]
            Additional arguments passed to awswrangler.athena.start_query_execution.

        Returns
        -------
        None

        Examples
        --------
        >>> ddl = '''
        >>>       CREATE OR REPLACE VIEW my_database.my_view AS
        >>>       SELECT * FROM my_database.my_table;
        >>>       '''
        >>> athena.create_view(database='my_database', query=ddl, wait=True)
        """
        self._check_valid_identifier(database)
        self._check_single_statement(query)
        self._check_query(query, [r'CREATE VIEW', r'CREATE OR REPLACE VIEW'], "Query is invalid; please use CREATE [ OR REPLACE ] VIEW to create a view")
        self._execute_query(query=query, database=database, **kwargs)

    def drop_view(self, database: str, view: str, **kwargs: Dict[str, Any]) -> None:
        """
        Drop a view in Athena in the specified database.

        Parameters
        ----------
        database: str
            The name of the database to drop the view from.
        view: str
            The name of the view to drop.
        **kwargs: Dict[str, Any]
            Additional arguments passed to awswrangler.athena.start_query_execution.

        Returns
        -------
        None

        Examples
        --------
        >>> athena.drop_view(database='my_database', view='my_view', wait=True)
        """
        self._check_valid_identifier(database)
        self._check_valid_identifier(view)
        query = f"DROP VIEW IF EXISTS {view};"
        self._check_single_statement(query)
        self._execute_query(query=query, database=database, **kwargs)

    def query(self, database: str, query: str, ctas_approach: bool = False, **kwargs: Any) -> pd.DataFrame:
        """
        Execute a query in Athena.

        Parameters
        ----------
        database: str
            The name of the database to start the query in; the query can reference other databases.
        query: str
            The query to execute.
        ctas_approach: bool, optional
            Use the Create Table As Select (CTAS) approach to execute the query.
        **kwargs: Any
            Additional arguments passed to awswrangler.athena.read_sql_query.

        Returns
        -------
        pd.DataFrame
            The result of the query.

        Examples
        --------
        >>> query = '''
        >>>         SELECT * FROM my_database.my_table
        >>>         WHERE date >= DATE '2021-01-01';
        >>>         '''
        >>> athena.query(database='my_database', query=query, ctas_approach=False)
        """
        self._check_valid_identifier(database)
        self._check_single_statement(query)
        return wr.athena.read_sql_query( 
            sql=query,
            database=database,
            ctas_approach=ctas_approach,
            s3_output=self.s3_output,
            boto3_session=self.boto3_session,
            **{k: v for k,v in kwargs.items() if k not in {'boto3_session', 's3_output', 'ctas_approach'}}
        )
