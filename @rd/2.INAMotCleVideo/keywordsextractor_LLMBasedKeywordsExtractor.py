import openai

class LLMBasedKeywordsExtractor:
    def __init__(self, custom_prompt):
        self.custom_prompt = custom_prompt

    def extract_keywords(self, text):
        prompt = f"{self.custom_prompt}\n\nTexte:\n{text}\n\nMots-clés:"  
        
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "Vous êtes un expert en extraction de mots-clés."},
                {"role": "user", "content": prompt}
            ]
        )
        
        keywords = response["choices"][0]["message"]["content"].strip()
        return [kw.strip() for kw in keywords.split(",") if kw.strip()]
