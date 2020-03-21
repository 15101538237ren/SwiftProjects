import UIKit

var str = "Hello, playground"

let x: Int = 10
var y: Double = 2.0
var sum:Double = Double(x) + y
print(sum)
y = 3
print(sum)

var greeting = "Hola!"
var name = "Peter, "
var price = 35.0
var content = "this hat is $ \(price)"
var titile = greeting + name + content
print(titile.uppercased())
print(titile.count)

var bookArray = ["Gone with the wind", "Sophine's World"]
bookArray[0]
bookArray.append("I am Honglei")
bookArray.count

for index in 0...2 {
    print(bookArray[index])
}

for index in 0...bookArray.count - 1{
    print(bookArray[index])
}


for book in bookArray {
    print(book)
}

var bookDict = ["1": "A", "2" : "B", "3" : "C"]

for (key, item) in bookDict{
    print("\(key) \(item)")
}

var emojiDict = ["😃": "Grinnin", "😂": "Tears of Joy", "😉": "Winking"]

var wordToLookUp = "😂"

var meaning = emojiDict[wordToLookUp]

let contentview = UIView(frame: CGRect(x:0, y:0, width:300, height: 300))
contentview.backgroundColor = UIColor.orange

let emojiLabel = UILabel(frame: CGRect(x: 90, y: 20, width: 160, height: 150))
emojiLabel.text = wordToLookUp
emojiLabel.font = UIFont.systemFont(ofSize: 100.0)

contentview.addSubview(emojiLabel)

let emojiMeaning = UILabel(frame: CGRect(x: 50 , y: 100, width: 200, height: 150))
emojiMeaning.text = meaning
emojiMeaning.font = UIFont.systemFont(ofSize: 30.0)
emojiMeaning.textColor = UIColor.white

contentview.addSubview(emojiMeaning)
