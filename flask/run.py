import pytest


retcode = pytest.main()


if retcode != 0: 
      print("failed awy")
elif retcode == 0:
      print("success awy")
