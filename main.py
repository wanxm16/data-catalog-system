import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List
import uvicorn

from models.schemas import (
    TableInfo, TableDetail, CatalogRequest, CatalogUpdateRequest,
    ChatRequest, ChatResponse, ApiResponse, CatalogInfo
)
from services.table_service import TableService
from services.ai_service import AIService
from services.rag_service import RAGService 