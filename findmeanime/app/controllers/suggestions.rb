#THIS IS A SET OF FUNCTIONS RELATED TO THE LOGIC OF THE PROGRAM, NOTABLY THE SUGGESTIONS ENGINE.  There are written as helper functions for get_suggestions, however, some probably have greater scope than that


#returns a tuple with the first row being show objects and the second show being suggestion scores
def get_suggestions(user)
#first, create a formatted list of shows to look through
  shows = weed_irrelevant(ALL_SHOWS, user.watched_animes);
  shows = weed_seen(shows, user.watched_animes);
  shows = make_twod(shows)
  #next, we assign a score to each show.  This is done by iterating through the list of seen shows, and for each show in possible suggestions, subtracting the percentage of users who disliked a suggested show from those who liked it.  Then, we add up these numbers for each show the given user has seen, generating a rating for each show.
  i=0;
  while(user.watched_animes[i].anime)
    j=0;
    current_anime = user.watched_animes[i].anime;
    current_rank = user.watched_animes[i].rank;
    while(shows[j,0])
      #calculate the percentage of users who have seen watched_animes[i] who have liked, disliked, and are neutral about shows[j]
      numliked = Float(certain_opinion(current_anime, shows[j,0], current_rank, 1).length);
      numhated = Float(certain_opinion(current_anime, shows[j,0], current_rank, -1).length);
      numneutral = Float(certain_opinion(current_anime, shows[j,0], current_rank, 0).length);
      total = numliked + numhated + numneutral;
      #calculate the portion of the rating of shows[j] generated by watched_animes[i]
      shows[j,1] = shows[j,1] + numliked/total - numhated/total;
      j = j + 1;
    end
    i = i + 1;
  end

  #finally, we sort the list by ratings and return it
  sorted_list = sort_by_score(shows);
  return sorted_list;
end

#tests if a given list of watched_animes includes a given show
def includes_show?(show, watched_animes)
  i = 0;
  while(watched_animes[i])
    if(watched_animes[i].anime==show)
      return true;
    end
    i = i + 1;
  end
  return false;
end


#removes shows from all_shows that are in my_shows in order to not suggest already watched programs.  note that my_shows is a list of watched_animes
def weed_seen(all_shows, my_shows)
  i = 0;
  k = 0;
  shows[0] = 0; #scope
  while(all_shows[i])
    if(not includes_show?(all_shows[i], my_shows))
      shows[k] = all_shows[i];
      k = k + 1;
    end
    i = i + 1;
  end
  return shows;
end


#returns a list of shows after removing all shows from all_shows that do not have any users who have also watched something from my_shows
def weed_irrelevant(all_shows, my_shows)
  i = 0;
  k = 0;
  shows[0] = 0; #scope
  while(all_shows[i])
    j = 0;
    while(my_shows[j])
      if(shared_user(all_shows[i], my_shows[j]))
         shows[k] = all_shows[i];
         k = k + 1;
      end
      j = j + 1;
    end
    i = i + 1;
  end
  return shows
end

#returns the first user who has seen both shows.  Otherwise returns nil
def shared_user(show1, show2)
  i = 0
  while(ALL_USERS[i])
    if(includes_show?(show1, ALL_USERS[i].watched_animes) and includes_show?(show2, ALL_USERS[i].watched_animes))
      return ALL_USERS[i]
    end
    i = i + 1;
  end
  return nil;
end

#creates a two dimensional array (the second dimension is default 0) for the shows
def make_twod(my_shows)
  i = 0;
  shows[0,0] = 0 #scope
  while(my_shows[i])
    shows[i,0] = my_shows[i];
    shows[i,1] = 0;
    i = i + 1;
  end
  return shows;
end

#insertion sort 2d showlist by scores
#this probably sorts in situ as well as a side effect (my knowledge of ruby lol).  This shouldn't be a concern in the context where it is used but if it gets used again beware
def sort_by_score(shows)
  i = 1;
  result_shows = shows;
  while(result_shows[i - 1,0])
    temp[0] = result_shows[i,0];
    temp[1] = result_shows[i,1];
    j = i;
    while(j > 0 and shows[j - 1, 0]>temp[i,0])
      result_shows[j,0] = result_shows[j-1,0];
      result_shows[j,1] = result_shows[j-1,1];
      j = j - 1;
    end
    result_shows[j,0] = temp[0];
    result_shows[j,1] = temp[1];
    i = i + 1;
  end
  return result_shows;
end


#returns a list of users of who felt a certain way about a show
def certain_opinion(show1, show2, score1, score2)
  i = 0;
  k = 0;
  result_users[0] = 0;#scope
  while(ALL_USERS[i])
    j = 0;
    user = ALL_USERS[i]
    while(user.watched_animes[j])
      animes = user.watched_animes;
      if(animes.includes_show?(show1) and animes.includes_show?(show2) and animes[j].rank==score1 and animes[j].rank==score2)
        result_users[k] = user;
        k = k+1;
      end
      j = j+1;
    end
    i = i + 1;
  end
  return result_users;
end
