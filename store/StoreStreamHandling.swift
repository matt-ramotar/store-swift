//
//  StoreStreamHandling.swift
//  store
//
//  Created by mramotar on 10/29/23.
//

import Foundation
import Combine







/**
 // If not in the memory cache, try to get data from the source of truth.
 self.requireLoadingPublishers(key: request.key).append(createLoadingPublisher(origin: .sourceOfTruth))
 self.requireDataPublishers(key: request.key).append((sourceOfTruth?.read(for: request.key)
     .flatMap { outputData -> AnyPublisher<StoreReadResponse<Output>, FetcherError> in
         // If data is found in the source of truth, validate it.
         if let outputData = outputData {
             return Future { promise in
                 Task {
                     do {
                         let isValid = await self.validator?.isValid(outputData) ?? true
                         
                         if isValid {
                             // If the data in the source of truth is valid, return it.
                             promise(.success(StoreReadResponse.data(value: outputData, origin: .sourceOfTruth)))
                             
                             if request.refresh {
                                 // If refresh is requested, fetch from network, write to source of truth, and return.
                                 await self.refresh(promise: promise, key: request.key, fallBackToSourceOfTruth: false)
                             }
                         } else {
                             // If it's not valid, fetch from network, write to source of truth, and return.
                             await self.refresh(promise: promise, key: request.key, fallBackToSourceOfTruth: false)
                         }
                     }
                 }
             }.eraseToAnyPublisher()
         } else {
             // If not, fetch from network, write to source of truth, and return.
             self.requireLoadingPublishers(key: request.key).append(self.createLoadingPublisher(origin: .fetcher(name: self.fetcher.name)))
             return self.fetchFromNetworkAndWriteToSourceOfTruth(key: request.key, fallBackToSourceOfTruth: false)
         }
     }
 )?.eraseToAnyPublisher() ?? fetchFromNetworkAndWriteToSourceOfTruth(key: request.key, fallBackToSourceOfTruth: false))
 */
