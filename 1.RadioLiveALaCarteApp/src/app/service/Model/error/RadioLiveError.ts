export interface ErrorInterface {
    prtErrorUUID: string;
    prtErrorCode: string;
    prtUserErrorMessage: string;
    prtErrorMessage: string;
    prtErrorDetails: string[];
}

export class RadioLiveError implements ErrorInterface {
    prtErrorUUID: string;
    prtErrorCode: string;
    prtUserErrorMessage: string;
    prtErrorMessage: string;
    prtErrorDetails: string[];

    constructor(
        prtErrorUUID: string,
        prtErrorCode: string,
        prtUserErrorMessage: string,
        prtErrorMessage: string,
        prtErrorDetails: string[]
    ) {
        this.prtErrorUUID = prtErrorUUID;
        this.prtErrorCode = prtErrorCode;
        this.prtUserErrorMessage = prtUserErrorMessage;
        this.prtErrorMessage = prtErrorMessage;
        this.prtErrorDetails = prtErrorDetails;
    }

    toString(): string {
        return `ErrorClass: {
            prtErrorUUID: ${this.prtErrorUUID},
            prtErrorCode: ${this.prtErrorCode},
            prtUserErrorMessage: ${this.prtUserErrorMessage},
            prtErrorMessage: ${this.prtErrorMessage},
            prtErrorDetails: ${this.prtErrorDetails.join(', ')}
        }`;
    }
}