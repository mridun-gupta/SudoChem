from __future__ import annotations
import pytest
from energy008.config import load_model

@pytest.fixture()
def base_data():
    return load_model()

@pytest.fixture()
def fixture(base_data):
    return base_data.fixture
