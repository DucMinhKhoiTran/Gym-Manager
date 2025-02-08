//
//  main.swift
//  Group1_Gym
//
//  Created by Duc Minh Khoi Tran on 2025-01-22.
//

import Foundation


// Protocol isPurchased
protocol isPurchased {
    var serviceInfo: String { get }
    func printReceipt(transaction: String, amount: Int)
}

// Service class
class Service: isPurchased, Hashable {
    let id: String
    let name: String
    let totalSessions: Int
    let price: Int
    
    init (id: String, name: String, totalSessions: Int, price: Int) {
        self.id = id
        self.name = name
        self.totalSessions = totalSessions
        self.price = price
    }
    var serviceInfo: String {
        return "Service ID: \(id)\nService Name: \(name)\nTotal Sessions: \(totalSessions)\nPrice: \(price)"
    }
    
    func printReceipt(transaction: String, amount: Int) {
        print("""
              Transaction: \(transaction)
              Service: \(name)
              Amount: \(amount) credits
              """)
    }
    
    // conform to Hashable
    static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

// FitnessClass Class
class FitnessClass: Service {
    let duration: Int
    let trainerName: String
    
    init(id: String, name: String, totalSessions: Int, price: Int, duration: Int, trainerName: String) {
        self.duration = duration
        self.trainerName = trainerName
        super.init(id: id, name: name, totalSessions: totalSessions, price: price)
    }
}

// Personal Training Class
class PersonalTraining: Service {
    let trainerName: String
    let sessionTime: String
    
    init(id: String, name: String, totalSessions: Int, price: Int, trainerName: String, sessionTime: String) {
        self.trainerName = trainerName
        self.sessionTime = sessionTime
        super.init(id: id, name: name, totalSessions: totalSessions, price: price)
    }
}

// Member Class
class Member {
    let id: String
    let name: String
    var creditBalance: Int = 100
    var bookedServices: [Service: Int] = [:] // Session Attended
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func bookService(service: Service) {
        if bookedServices.keys.contains(service) && bookedServices[service]! < service.totalSessions {
            print("Service already booked and not completed.")
            return
        }
        if creditBalance >= service.price {
            creditBalance -= service.price
            bookedServices[service] = 0
            service.printReceipt(transaction: "Booked", amount: service.price)
        } else {
            print("Insufficient credits!")
        }
    }
    func cancelService(service: Service) {
        if let attendedSessions = bookedServices[service], attendedSessions == 0 {
            creditBalance += service.price
            bookedServices.removeValue(forKey: service)
            service.printReceipt(transaction: "Cancelled", amount: service.price)
        } else {
            print("Cancellation now allowed (session attended).")
        }
    }
    
    func markAttendance(service: Service) {
        if let attendedSessions = bookedServices[service] {
            if attendedSessions + 1 < service.totalSessions {
                bookedServices[service]! += 1
                print("Marked attendance for \(service.name).")
            } else if attendedSessions + 1 == service.totalSessions {
                bookedServices[service]! += 1
                print("Congratulation on completing \(service.name)!")
            } else {
                print("Service already completed/")
            }
        } else {
            print("Service not booked.")
        }
    }
    
    func viewBookedServices() {
        print("Booked Services:")
        for (service, attended) in bookedServices {
            print("\(service.serviceInfo), Sessions Attended: \(attended)")
        }
    }
}

// Gym Class
class Gym {
    var services: [Service] = []
    var members: [Member] = []
    
    func addServices(service: Service) {
        services.append(service)
    }
    
    func searchService(keyword: String){
        let results = services.filter{ $0.name.lowercased().contains(keyword.lowercased())}
        if results.isEmpty {
            print("No services found for keyword: \(keyword)")
            }else {
                results.forEach { print($0.serviceInfo) }
            }
    }
    
    func listServices() {
        print("Available Services:")
        services.forEach { print($0.serviceInfo) }
    }
    func addMember(member: Member) {
        members.append(member)
    }
}

let gym = Gym()

func showMainMenu() {
    print("""
    Welcome to Group#_Gym!
    Please select your role:
    1. Gym Owner
    2. Gym Member
    3. Exit
    """)
}

func gymOwnerMenu() {
    
    var choice: Int?
    repeat {
        print("""
                Gym Owner Menu:
                1. Add Service
                2. List Services
                3. Search Service
                4. Exit
                """)
        choice = Int(readLine() ?? "")
        
        if let choice = choice {
            switch choice {
            case 1:
                print("Enter Service Type (1: FitnessClass, 2: PersonalTraining):")
                let type = Int(readLine() ?? "") ?? 0
                print("Enter ID: ")
                let id = readLine() ?? ""
                print("Enter Name:")
                let name = readLine() ?? ""
                print("Enter Total Sessions:")
                let totalSessions = Int(readLine() ?? "") ?? 0
                print("Enter Price: ")
                let price = Int(readLine() ?? "") ?? 0
                
                if type == 1 {
                    print("Enter Duration:")
                    let duration = Int(readLine() ?? "") ?? 0
                    print("Enter Trainer Name:")
                    let trainerName = readLine() ?? ""
                    let fitnessClass = FitnessClass(id: id, name: name, totalSessions: totalSessions, price: price, duration: duration, trainerName: trainerName)
                    gym.addServices(service: fitnessClass)
                } else if type == 2 {
                    print("Enter Trainer Name:")
                    let trainerName = readLine() ?? ""
                    print("Enter Session Time:")
                    let sessionTime = readLine() ?? ""
                    let personalTraining = PersonalTraining(id: id, name: name, totalSessions: totalSessions, price: price, trainerName: trainerName, sessionTime: sessionTime)
                    gym.addServices(service: personalTraining)
                }
                print("Service added successfully!")
                
            case 2:
                gym.listServices()
            case 3:
                print("Enter keyword to search:")
                let keyword = readLine() ?? ""
                gym.searchService(keyword: keyword)
            case 4:
                print("Exit Gym Owner Menu")
            default:
                print( "Invalid choice")
            }
        }
    } while choice != 4
}

func gymMemberMenu() {
    var choice: Int?
    var currentMember: Member? = nil
    
    repeat {
        print("""
        Gym Member Menu:
        1. Join Gym
        2. Reload Credits
        3. Book Service
        4. Cancel Service
        5. Mark Attendance
        6. View Booked Services
        7. Exit
        """)
        choice = Int(readLine() ?? "") ?? 0
        
        switch choice {
        case 1:
            print("Enter Member ID:")
            let id = readLine() ?? ""
            print("Enter Member Name:")
            let name = readLine() ?? ""
            let member = Member(id: id, name: name)
            gym.addMember(member: member)
            currentMember = member
            print("Welcome to the gym, \(name)!")
        case 2:
            guard let member = currentMember else {
                print("Please join the gym first!")
                break
            }
            print("Enter credits to reload:")
            let credits = Int(readLine() ?? "") ?? 0
            member.creditBalance += credits
            print("Credits reloaded! New balance: \(member.creditBalance)")
        case 3:
            guard let member = currentMember else {
                print("Please join the gym first!")
                break
            }
            gym.listServices()
            print("Enter Service ID to book:")
            let serviceID = readLine() ?? ""
            if let service = gym.services.first(where: { $0.id == serviceID }) {
                member.bookService(service: service)
            } else {
                print("Service not found.")
            }
        case 4:
            guard let member = currentMember else {
                print("Please join the gym first!")
                break
            }
            print("Enter Service ID to cancel:")
            let serviceID = readLine() ?? ""
            if let service = gym.services.first(where: { $0.id == serviceID }) {
            member.cancelService(service: service)
            } else {
                print("Service not found.")
            }
        case 5:
            guard let member = currentMember else {
                print("Please join the gym first!")
                break
                }
                print("Enter Service ID to mark attendance:")
                let serviceID = readLine() ?? ""
                if let service = gym.services.first(where: { $0.id == serviceID }) {
                    member.markAttendance(service: service)
                } else {
                    print("Service not found.")
                }
        case 6:
            currentMember?.viewBookedServices() ??
            print("Please join the gym first!")
        case 7:
            print("Exiting Gym Member Menu.")
        default:
            print("Invalid choice.")
        }
    } while choice != 7
}

var choice: Int?
repeat {
    showMainMenu()
    choice = Int(readLine() ?? "") ?? 0
    
    switch choice {
    case 1:
        gymOwnerMenu()
    case 2:
        gymMemberMenu()
    case 3:
        print( "Exiting...")
    default:
        print("Invalid choice. Please try again.")
    }
} while choice != 3
