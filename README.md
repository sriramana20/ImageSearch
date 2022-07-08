# Photo-Gallery

Functionalities
1.User can search photo and will see list of images   
2.on swipe of each row user can see two options(share,save)
3.user can share email 
4.user can save in photos

Architecture
It is using MVVM architecture
The UI is created using UIKit framework
It is using combine framework for data binding
It uses repositorty pattern to communictate between network layer and storage layer
Other patterns used are: singleton, protocol extension, dependancy injections
#Testing

1.Unit Test cases are there for viewmodel 
2.Mocking and stubbing is used to test network layer and core data layer
