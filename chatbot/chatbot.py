#!/usr/bin/env python3
"""
chatbot.py
----------
RAG chatbot يجاوب عن:
  - كتاب xv6
  - كود المشروع المطور (functions, kernel, user)

يستخدم OpenRouter API + ChromaDB محلي
"""

import os
import sys
from pathlib import Path

import chromadb
from chromadb.utils import embedding_functions
from openai import OpenAI   # OpenRouter متوافق مع OpenAI client


CHROMA_DIR    = "./chroma_db"
COLLECTION    = "xv6_knowledge"
EMBED_MODEL   = "all-MiniLM-L6-v2"
OPENROUTER_KEY = os.environ.get("OPENROUTER_API_KEY", "")
LLM_MODEL     = "openai/gpt-4o-mini"
TOP_K         = 6   
MAX_TOKENS    = 1024


SYSTEM_PROMPT = """You are an expert assistant for the xv6 educational operating system project.
You have access to:
1. The xv6 RISC-V book (PDF) — theory, concepts, explanations
2. The modified xv6 source code — kernel and user programs with custom additions

When answering:
- Be precise and technical
- Reference specific files or functions when relevant (e.g., kernel/proc.c, allocproc())
- If the question is about a custom addition to xv6, mention it explicitly
- If you don't find relevant info in the context, say so honestly
- Answer in the same language the user writes in (Arabic or English)
"""


# ─── ChromaDB ──────────────────────────────────────────────────────────────
def load_db():
    if not Path(CHROMA_DIR).exists():
        print("[ERR] chroma_db not found! Run ingest.py first.")
        sys.exit(1)
    ef = embedding_functions.SentenceTransformerEmbeddingFunction(
        model_name=EMBED_MODEL
    )
    client = chromadb.PersistentClient(path=CHROMA_DIR)
    col    = client.get_collection(name=COLLECTION, embedding_function=ef)
    print(f"[DB] Loaded {col.count()} documents")
    return col


# ─── Retrieval ─────────────────────────────────────────────────────────────
def retrieve(collection, query: str, top_k=TOP_K) -> str:
    results = collection.query(
        query_texts=[query],
        n_results=top_k,
        include=["documents", "metadatas", "distances"]
    )
    docs      = results["documents"][0]
    metadatas = results["metadatas"][0]
    distances = results["distances"][0]

    context_parts = []
    for doc, meta, dist in zip(docs, metadatas, distances):
        source = meta.get("source", "unknown")
        # فلتر: تجاهل نتائج بعيدة جداً (cosine distance > 0.8)
        if dist > 0.8:
            continue
        context_parts.append(f"[Source: {source}]\n{doc}")

    return "\n\n---\n\n".join(context_parts)


# ─── OpenRouter LLM ────────────────────────────────────────────────────────
def build_client():
    if not OPENROUTER_KEY:
        print("[ERR] OPENROUTER_API_KEY not set!")
        sys.exit(1)
    return OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=OPENROUTER_KEY,
    )


def ask_llm(client, messages: list) -> str:
    response = client.chat.completions.create(
        model=LLM_MODEL,
        messages=messages,
        max_tokens=MAX_TOKENS,
        temperature=0.3,   # منخفض للإجابات التقنية
        extra_headers={
            "HTTP-Referer": "https://github.com/ruba-alsawaf/xv6-educational",
            "X-Title": "xv6 Educational Chatbot"
        }
    )
    return response.choices[0].message.content


# ─── Chatbot Class ─────────────────────────────────────────────────────────
class XV6Chatbot:
    def __init__(self):
        print("[INFO] Loading xv6 RAG Chatbot...")
        self.collection = load_db()
        self.llm_client = build_client()
        self.history    = []   # conversation history
        print("[INFO] Ready!\n")

    def chat(self, user_message: str) -> str:
        # 1. استرجاع السياق من DB
        context = retrieve(self.collection, user_message)

        # 2. بناء الـ messages
        messages = [{"role": "system", "content": SYSTEM_PROMPT}]

        # أضف السياق كـ system message ثاني
        if context:
            messages.append({
                "role": "system",
                "content": f"Relevant context from xv6 book and code:\n\n{context}"
            })

        # أضف تاريخ المحادثة (آخر 6 رسائل بس)
        messages += self.history[-6:]

        # أضف السؤال الجديد
        messages.append({"role": "user", "content": user_message})

        # 3. اسأل الـ LLM
        answer = ask_llm(self.llm_client, messages)

        # 4. احفظ بالتاريخ
        self.history.append({"role": "user",      "content": user_message})
        self.history.append({"role": "assistant", "content": answer})

        return answer

    def reset(self):
        """امسح تاريخ المحادثة"""
        self.history = []
        return "Conversation reset."


# ─── CLI للتجربة المباشرة ───────────────────────────────────────────────────
if __name__ == "__main__":
    bot = XV6Chatbot()
    print("xv6 Chatbot ready. Type 'quit' to exit, 'reset' to clear history.\n")
    print("-" * 50)

    while True:
        try:
            user_input = input("\nYou: ").strip()
        except (KeyboardInterrupt, EOFError):
            print("\nBye!")
            break

        if not user_input:
            continue
        if user_input.lower() == "quit":
            print("Bye!")
            break
        if user_input.lower() == "reset":
            print(bot.reset())
            continue

        print("\nBot: ", end="", flush=True)
        answer = bot.chat(user_input)
        print(answer)