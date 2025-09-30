//
//  FileDownloader.swift
//  pos
//
//  Created by Khaled on 3/19/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation


protocol FileDownloaderDelegate {
    func progress(value:Float)
    func downloadeComplete(path:String?,error:Error?)
}

class FileDownloader :NSObject, URLSessionDelegate,URLSessionTaskDelegate,URLSessionDownloadDelegate {

    var delegate:FileDownloaderDelegate?
    var localURL:URL!
    
      func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
           SharedManager.shared.printLog("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
               SharedManager.shared.printLog("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
               SharedManager.shared.printLog("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

      func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
           SharedManager.shared.printLog("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
    
    
    func loadFileAsync2(url: URL)
       {
        localURL = url
 
           let destinationUrl = getdestinationUrl()

           if FileManager().fileExists(atPath: destinationUrl.path)
           {
              SharedManager.shared.printLog("File already exists [\(destinationUrl.path)]")
              delegate?.downloadeComplete(path: destinationUrl.path, error: nil)
           }
           else
           {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
             
            let downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
              
           }
       }
    
    func getdestinationUrl()-> URL
    {
        let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

                 let destinationUrl = documentsUrl.appendingPathComponent(localURL.lastPathComponent)
        
        return destinationUrl
    }
    
    // MARK:- URLSessionDownloadDelegate
       func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
       SharedManager.shared.printLog("File download succesfully")
        
        let fileManager = FileManager()
        let destinationURLForFile = getdestinationUrl()
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            try? fileManager.removeItem(at: destinationURLForFile)
        }
        
        do {
            try fileManager.moveItem(at: location, to: destinationURLForFile)
            // show file
            delegate?.downloadeComplete(path:  destinationURLForFile.path, error: nil)
        }catch{
           SharedManager.shared.printLog("An error occurred while moving file to destination url")
            delegate?.downloadeComplete(path:  nil , error: nil)
            
        }
        
        
   
        
       }
 
    
       func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
           let progress =  Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
          
        delegate?.progress(value: progress)
//           SharedManager.shared.printLog(progress)

//           progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        
       }

       func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//           downloadTask = nil
//           progressView.setProgress(0.0, animated: true)
//           if (error != nil) {
//              SharedManager.shared.printLog("didCompleteWithError \(error?.localizedDescription ?? "")")
//           }
//           else {
//              SharedManager.shared.printLog("The task finished successfully")
//           }
       }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
         completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
      

    }
    
    
}
