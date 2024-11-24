import { User } from "./User";

export class UserHelper {

    public static build(id: string,
        firstName: string,
        lastName: string): User {
        return { 
            id: id,
            firstName: firstName,
            lastName: lastName,
        } as User;
    }

    public static toString(user: User) {
        return ``;
    }


}