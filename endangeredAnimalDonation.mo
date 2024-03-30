import Debug "mo:base/Debug";
import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor {
  type Name = Text;
  type Surname = Text;
  type Email = Text;
  type Phone = Text;
  type Password = Text;

  enum DonationType = {
    OneTime;
    Recurring;
    Adoption;
  };

  type Entry = {
    name : Name;
    surname : Surname;
    email : Email;
    phone : Phone;
    password : Password;
    donationType : DonationType;
    donations : Nat; 
  };

  let users = Map.HashMap<Email, Entry>(0, Text.equal, Text.hash);

  public func register(name: Name, surname: Surname, email: Email, phone: Phone, password: Password) : async () {
    let entry = {
      name = name;
      surname = surname;
      email = email;
      phone = phone;
      password = password;
      donationType = DonationType.OneTime; 
      donations = 0; 
    };
    users.put(email, entry);
  };

  public query func lookupByEmail(email: Email) : async ?Entry {
    users.get(email);
  };

  public func updateDonationType(email: Email, donationType: DonationType) : async () {
    let entry = await users.get(email);
    switch (entry) {
      case (?userEntry) => {
        userEntry.donationType = donationType;
        users.put(email, userEntry);
      };
      case (null) => {
        throw makeUserNotFoundError();
      };
    }
  };

  type UserNotFoundError = {
    message : Text;
  };

  public func makeUserNotFoundError() : UserNotFoundError {
    { message = "User not found." }; 
  };

  public func donate(email: Email, amount: Nat) : async () {
    let entry = await users.get(email);
    switch (entry) {
      case (?userEntry) => {
        userEntry.donations += amount;
        users.put(email, userEntry);
        Debug.print("Donation completed. Thank you for your support!"); 
      };
      case (null) => {
        Debug.print("Error: User not found. Donation failed."); 
        throw makeUserNotFoundError();
      };
    }
  };
};
