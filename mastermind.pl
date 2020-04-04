/** guess2(+Goal, -Res).
* Point d'entrée principal du programme avec l'algorithme de Knuth.
* Il prend en paramètre une solution (Goal) de couleurs ([c1,c2,c3,C4]) 
* et affiche les propositions et le score correspondant ([Nblacks,Nwhites]) 
* jusqu'à la solution en appelant guessIterate2/4.
* Nblacks pour le nombre de pions bien placés.
* Nwhites pour le nombre de pions mal placés.
*/
guess2(Goal,Res):-
    makeGuess(Goal), %verifie le format
    findall(Guess, makeGuess(Guess), CandidatesList), %toutes les propositions
    guessIterate2(Goal, [], CandidatesList, Res),!.

guessIterate2(Goal, Guesses, CandidatesList, Res):-
    reduceCandidates(CandidatesList, Guesses, ResList),
    minimax(Guess, ResList, Guesses),
    score(Guess, Goal, ThisScore),
	(  ThisScore == [4, 0]
	->
		Res = Guess
	;
		format("~w ~w\n", [Guess, ThisScore]),
		guessIterate2(Goal, [guess(Guess, ThisScore) | Guesses], ResList, Res)
	).


/** minimax(-Guess, +CandidatesList, +Guesses).
* Ce prédicat trouve la proposition (Guess) en appliquant l'algorithme minimax
* Il calcule le poids maximum pour toute possibilité.
* Il prend comme Guess, celle qui a le poids minimum.
+ On choisit 
*/
minimax([red,red,blue,blue],_,[]):-!.
minimax(Guess, CandidatesList, Guesses):-
    calculateMaximumList(CandidatesList, Guesses, Maximum), % ou maximumEtoile(CandidatesList, Maximum), %pour Knuth-etoile
    minWeight(Maximum, MinWeight),
    minimum(Maximum, MinWeight, CandidatesList, Guess).
  
/** reduceCandidates(+CandidatesList, +Guesses, -ResList).
* Il prend en arguments une liste de propositions (CandidatesList)
* et calcule la liste des propositions restantes (ResList)
* en considérant les configurations déjà jouées (Guesses).
*/
reduceCandidates([],_,[]).
reduceCandidates([Guess|CandidatesList], Guesses, [Guess|ResList]):-
    check_against_guesses(Guess, Guesses),
    reduceCandidates(CandidatesList, Guesses, ResList),!.
reduceCandidates([_|CandidatesList], Guesses, ResList):-
    reduceCandidates(CandidatesList, Guesses, ResList).
 
 
/** calculateMaximumList(+CandidatesList, +Guesses, -MaxList).
* Ce prédicat calcule le poids maximum de toutes les possibilités
* Ce poids correspond au nombre maximum de même score obtenu 
* avec les possibilités restantes (CandidatesList).
*/
calculateMaximumList(CandidatesList, Guesses, MaxList):-
    findall([Guess1, WeightMax], 
        (makeGuess(Guess1),
        not(member(guess(Guess1,_), Guesses)), %la configuration n'est pas déjà proposée.
        calculateScore(Guess1, CandidatesList, ScoreList),
        calculateWeight(ScoreList, ScoreList, WeightList), 
        maximum(WeightList, WeightMax)), 
    MaxList).


/** maximumEtoile(+CandidatesList, -MaxList).
* Ce prédicat est propre à notre stratégie Knuth-etoile.
* Il ne calcule le poids maximum que des possibilités candidates
*/
maximumEtoile(CandidatesList, MaxList):-
    findall([Guess1, WeightMax], 
        (member(Guess1,CandidatesList),
        calculateScore(Guess1, CandidatesList, ScoreList),
        calculateWeight(ScoreList, ScoreList, WeightList), 
        maximum(WeightList, WeightMax)), 
    MaxList).


/** calculateScore(+Guess, +CandidatesList, -ScoreList).
* Il calcule les scores obtenus en comparant
* la configuration (Guess) et la liste des propositions candidates (restantes).
*/
calculateScore(_,[],[]).
calculateScore(Guess, [Candidate|CandidatesList], [Score|ScoreList]):-
    score(Candidate, Guess, Score), 
    calculateScore(Guess, CandidatesList, ScoreList).
    

/** calculateWeight(+AllScoreList, +ScoreList, -WeightList).
* Il calcule le nombre d'occurrences de chaque score dans ScoreList,
* en faisant appel au prédicat numberOfOccurrences.
*/
calculateWeight(_,[],[]).
calculateWeight(AllScoreList, [Score|ScoreList], [Weight|WeightList]):-
    numberOfOccurrences(Score, AllScoreList, Weight),
    calculateWeight(AllScoreList, ScoreList, WeightList).
    
numberOfOccurrences(Score, ScoreList, Weight) :-
    include(=(Score), ScoreList, L), 
    length(L, Weight).


/** maximum(+WeightList, -MaxWeight).
* Ce prédicat prend une liste de poids (WeightList)
* et calcule le poids maximal (MaxWeight).
*/
maximum([MaxWeight], MaxWeight):-!.
maximum([Head|Tail], Res):- 
    maximum(Tail, Res2), 
    (Head>Res2->Res=Head; Res=Res2).


/** minimum(+MaxList, +MinWeight, +CandidatesList, -Guess).
* On choisit de préférence la configuration (Guess) 
* qui se trouve parmi les propositions candidates (CandidatesList).
* Le cas échéant, on choisit la première possibilité 
* qui possède le poids minimum.
*/
minimum(MaxList, MinWeight, CandidatesList, Guess):-
    (member([Guess, MinWeight], MaxList),
     member(Guess, CandidatesList),!)
    ; 
    (member([Guess, MinWeight], MaxList),!). 


/** minWeight(+MaximumList,-MinWeight).
* Ce prédicat calcule le poids minimal d'une liste.
*/
minWeight([[_,  Weight]], Weight):-!.
minWeight([[_,Weight]|Tail], Res):- 
    minWeight(Tail, Weight2),
    (Weight=<Weight2->Res=Weight; Res=Weight2).


/** Guess(+Goal, -Res).
* Point d'entrée principal du programme.
* Il prend en paramètre une solution (Goal) de couleurs ([c1,c2,c3,C4]) 
* et affiche les propositions et le score correspondant ([Nblacks,Nwhites]) 
* jusqu'à la solution en appelant guessIterate/3.
* Nblacks pour le nombre de pions bien placés.
* Nwhites pour le nombre de pions mal placés.
*/
guess(Goal, Res) :-
	guessIterate(Goal, [], Res),!.

guessIterate(Goal, Guesses, Res) :-
	makeGuess(Guess),
	check_against_guesses(Guess, Guesses),
	score(Guess, Goal, ThisScore),
	(
		%% if completely correct,...
		ThisScore == [4, 0]
	->
		Res = Guess
	;
		format("~w ~w\n", [Guess, ThisScore]),
		guessIterate(Goal, [guess(Guess, ThisScore) | Guesses], Res)
	).
    
    
/** check_against_guesses(+Guess, +Guesses).
* Ce prédicat prédit la bonne proposition (Guess) 
* en fonction des configurations précédentes (Guesses).
* En gros, il "supprime" les possibilités qui ne donnent pas le meme score 
* qu'on a obtenu avec les propositions précédentes.
*/
check_against_guesses(_, []).
check_against_guesses(Guess, [guess(Code, Score) | Guesses_tail]) :-
	score(Code, Guess, Score),
	check_against_guesses(Guess, Guesses_tail).
    
    
/** makeGuess(?Guess).
* Ce prédicat peut : 
* Fournir toutes les configurations possibles.
* Vérifier si une configuration est correcte.
*/
makeGuess(Guess) :-
	Colours = [red,blue,green,yellow,pink,purple],
    length(Guess, 4),
    maplist(list_member(Colours), Guess).

list_member(Ls, M) :- member(M, Ls).


/** score(+Guess, +Goal, -Res).
* Il prend des configurations proposée (Guess) et cachée (Goal)
* et stocke le score ([Black,White]) dans Res.
* Il fait d'abord appel à pass1 pour connaitre les pions bien placés (black),
* ensuite à pass2 pour connaitre les pions mal placés (white),
* et enfin, compte les nombres de "black" et "white" avec count_up. 
*/
score(Guess, Goal, Res) :-
	pass1(Guess, Goal, [], GuessModified, [], GoalModified),
	pass2(GuessModified, GoalModified, Pass2Res),
	count_up(Pass2Res, Res).

/** pass1(+Guess, +Goal, ?AccGuess, -GuessModified, ?AccGoal, -GoalModified).
* Ce prédicat compare la proposition (Guess) avec la solution (Goal) élement par élément 
* et change l'élément dans Goal en 'black' s'il y a une correspondance bien placée.
* Par ailleurs, le code ne fonctionnait que pour les configurations 
* avec des pions de couleurs différentes. 
* Il a été modifié afin de généraliser au cas des configurations 
* contenant éventuellement plusieurs pions d’une même couleur.
*/
pass1(_, [], AccGuess, GuessMofified, AccGoal, GoalModified) :-
	reverse(AccGoal, GoalModified),
    	reverse(AccGuess, GuessMofified).

pass1([Guess_head | Guess_tail], [Goal_head | Goal_tail], AccGuess, GuessModified, AccGoal, GoalModified) :- 
	(
		Guess_head == Goal_head
	->
		pass1(Guess_tail, Goal_tail, [used|AccGuess], GuessModified, [black | AccGoal], GoalModified)
	;
		pass1(Guess_tail, Goal_tail, [Guess_head|AccGuess], GuessModified, [Goal_head | AccGoal], GoalModified)
	).


/** pass2(+GuessModified, +GoalModified, -Res).
* Ce prédicat compare la proposition (Guess) avec la solution (Goal) élement par élément 
* et change l élément dans Goal en 'white' sil y a une correspondance mal placée
* en faisant appel à pass2Helper.
*/
pass2([], Goal, Goal_reversed) :-
	reverse(Goal, Goal_reversed).

pass2([Guess_head | Guess_tail], Goal, Res) :-
	pass2Helper(Guess_head, Goal, [], ModifiedGoal),
	pass2(Guess_tail, ModifiedGoal, Res).

pass2Helper(_, [], Acc, Acc_reversed) :-
	reverse(Acc, Acc_reversed).

pass2Helper(Guess, [Goal_head | Goal_tail], Acc, Res) :-
	(
		Guess == Goal_head
	->
		reverse(Goal_tail, Goal_tail_reversed),
		append(Goal_tail_reversed, [white | Acc], Res)
	;
		pass2Helper(Guess, Goal_tail, [Goal_head | Acc], Res)
	).


/** count_up(+Result_of_scoring, -[Blacks, Whites]).
* Ce prédicat compte le nombre de "blacks" et de "whites",
* ce qui correspond au score.
*/
count_up(Result_of_scoring, [Blacks, Whites]) :-
	count_colour(white, Result_of_scoring, Whites),
	count_colour(black, Result_of_scoring, Blacks).
		
count_colour(Colour, Input, Count) :-
	include( =(Colour), Input, Out),
	length(Out, Count). 