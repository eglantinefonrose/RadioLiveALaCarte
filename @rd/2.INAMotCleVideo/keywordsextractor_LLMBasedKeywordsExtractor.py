import openai
import json
import os
from mistralai import Mistral

class LLMBasedKeywordsExtractor:
    def __init__(self, custom_prompt):
        self.custom_prompt = custom_prompt

    def extract_keywords(self, text):
        '''prompt = f"{self.custom_prompt}\n\nTexte:\n{text}\n\nRéponse attendue au format JSON:"

        client = openai.OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

        response = client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system",
                 "content": "Vous êtes un expert en extraction de mots-clés. Répondez uniquement avec un JSON valide."},
                {"role": "user", "content": prompt}
            ]
        )

        keywords_json = response.choices[0].message.content.strip()

        try:
            return json.loads(keywords_json)
        except json.JSONDecodeError:
            return {"mots_cles_video": [], "mots_cles_sujet": []}'''

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
        print(chat_response.choices[0].message.content)
        return (chat_response.choices[0].message.content)





