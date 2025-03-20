import numpy as np
from transformers import TokenClassificationPipeline, AutoModelForTokenClassification, AutoTokenizer
from transformers.pipelines import AggregationStrategy


class KeyphraseExtractionPipeline(TokenClassificationPipeline):
    def __init__(self, model, *args, **kwargs):
        super().__init__(
            # Charge un modèle pré-entraîné pour la classification de tokens
            # Ici, un token est une unité de texte utilisée par le modèle de traitement du langage
            model=AutoModelForTokenClassification.from_pretrained(model),

            # Charge le tokenizer correspondant au modèle
            tokenizer=AutoTokenizer.from_pretrained(model),
            *args,
            **kwargs
        )

    def postprocess(self, all_outputs):
        results = super().postprocess(
            all_outputs=all_outputs,
            aggregation_strategy=AggregationStrategy.SIMPLE,
        )
        return np.unique([result.get("word").strip() for result in results])
