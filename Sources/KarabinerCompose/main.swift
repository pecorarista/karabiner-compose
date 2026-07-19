import Foundation

let data = try KarabinerJSONEncoder.encode(DefaultProfile.profile)
FileHandle.standardOutput.write(data)
FileHandle.standardOutput.write(Data("\n".utf8))