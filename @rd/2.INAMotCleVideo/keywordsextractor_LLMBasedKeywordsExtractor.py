import openai
import json
import os
from mistralai import Mistral

class LLMBasedKeywordsExtractor:
    def __init__(self, custom_prompt):
        self.custom_prompt = custom_prompt

    def extract_keywords(self, text):

        api_key = os.environ["MISTRAL_API_KEY"]
        model = "mistral-large-latest"

        client = Mistral(api_key=api_key)

        chat_response = client.chat.complete(
            model= model,
            messages = [
                {
                    "role": "user",
                    "content": f"{self.custom_prompt}\n\nTexte:\n{text}\n\nRéponse attendue au format JSON:",
                },
            ]
        )
        return (chat_response.choices[0].message.content)





