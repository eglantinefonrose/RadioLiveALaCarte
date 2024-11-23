export interface RadioLiveErrorInterface {
    prtErrorUUID: string;
    prtErrorCode: string;
    prtUserErrorMessage: string;
    prtErrorMessage: string;
    prtErrorDetails: any[]; // ou un type plus spécifique si connu
}