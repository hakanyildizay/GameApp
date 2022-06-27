#  How much time was invested

* Totally I spent 10 hours for this project.

#  How was the time distributed

* Milestone1 - 4 hours
* Milestone2 - 3 hours
* Milestone3 - 3 hours

#  Decisions made to solve certain aspect of the game

* The application's architecture is MVVM. View (***GameViewController***) and ViewModel (***GameViewModel***) are communicating using protocol ***GameProtocol***. This way it is easy to isolate the business rule inside ***GameViewModel***. And it is also make it clear to write unit tests for the game logic.


#  Decisions made because of restricted time

* GameViewModel has a concrete class dependency to WordDataSource. It might be great if we can inject DataSource protocol instead of object type. Because for the sake of flexibility
we may need to have that data coming over network. So I leave it as object dependency because of shortage of time.

* I could use RxSwift in this project, but I feel more comfortable using protocol oriented approach. If I had more time I could try to adapt RxSwift.

* For the ***Word*** model class I could use [CodingKeys](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types) in order to differentiate property name and the key name. Since I run out of time I do not prefer to do changes right now.  

* Every case may not be handled by GameViewModel. Some methods may need to raise Error in case of unknown states. So View class (***GameViewController***) may need to implement one more function to listen all errors from ***GameViewModel***.

* If I have more time I would like to prevent loading ***GameViewController*** when running UnitTests. Because I would rather use mock classes instead of actual ***GameViewController*** class.

* ***GameViewModel*** should not expose ```attemptScore``` property to the **View** class. It should be protected and can be accessed only through protocol method. So **ViewModel** should notify the **View** when score is updated with ```scoreUpdated(newScore: )``` method. Since I run out of time I do not prefer to do changes right now.    

#  What would be the first thing to improve or add if there has been more time

* The first thing would be is to add Error handling mechanism. For example, in ***GameViewModel***,  ```select()``` and ```askForNextQuestions()``` methods should be tested with more scenarios. And each needs to deliver appropriate errors to the **View** if there are two successive method calls.  
