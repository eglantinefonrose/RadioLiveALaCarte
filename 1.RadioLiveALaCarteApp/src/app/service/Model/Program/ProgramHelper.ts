import { Program } from "./Program";

export class ProgramHelper {
    public static build(id: string,
        radioName: string,
        startTimeHour: number,
        startTimeMinute: number,
        startTimeSeconds: number,
        endTimeHour: number,
        endTimeMinute: number,
        endTimeSeconds: number): Program {
        return { 
            id: id,
            radioName: radioName,
            startTimeHour: startTimeHour,
            startTimeMinute: startTimeMinute,
            startTimeSeconds: startTimeSeconds,
            endTimeHour: endTimeHour,
            endTimeMinute: endTimeMinute,
            endTimeSeconds: endTimeSeconds
        } as Program;
    }
    
    public static toString(program: Program) {
        return ``;
    }
}