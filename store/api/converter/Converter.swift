import Foundation

protocol Converter {
    associatedtype Network
    associatedtype Local
    associatedtype Output
    
    func fromNetworkToOutput(_ network: Network) -> Output
    func fromOutputToLocal(_ output: Output) -> Local
    func fromNetworkToLocal(_ network: Network) -> Local
}
