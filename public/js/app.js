$( document ).ready(function() {
  function notice(message) {
    var noticeDiv = $('<div class="notice"><p class="notice-message">'+message+'</p></div>');
    $('.notice-block').append(noticeDiv.fadeIn(500).delay(3000).fadeOut(500));
  };

  function mark_guess(guess_result) {
    result = "";
    for (i=0 ;i<guess_result[0]; i++) {
      result += '+';
    }          

    for (i=0; i<guess_result[1]; i++) {
      result += '-';
    }

    return result;
  }

  function ajax_post(url,data,cb) {
    $.ajax({
      type: 'POST',
      url: url,
      async: true,
      cache: false,
      data: data,

      success: function(jsonData,textStatus,jqXHR) {
        if (typeof(cb) == 'function') {
          cb(jsonData);
        }
      },
      error: function(XMLHttpRequest, textStatus, errorThrown){
        notice(XMLHttpRequest);
        notice(textStatus);
        notice(errorThrown);
      }
    });
  }

  $('#start_game_btn').click(function(event) {
    ajax_post('/start', null ,function(jsonData) {
      if (jsonData.status == 'game_started') {
        $('#game_block').hide();
        $('#start_game_btn').hide();
          var form = $('  <form>\
                          <input id="guessField" name="text" type="text">\
                        </form>');
          var hint  = $('<button id="hint">Hint</button>');
          var restart = $('<button id="restart">Restart</button>');

          guess = $('<input id="guess" type="button" value="guess!">')

          guess.click(function(event) {
            ajax_post('/guess','guess=' + $('#guessField').val(), function(jsonData) {
              if (jsonData.status == 'invalid_input') {
                notice(jsonData.text);
              } else if (jsonData.status == 'game_over') {
                notice(jsonData.text);
                $('#guess').hide();
                $('#hint').hide();
                
                var show_history = $('<button id="show_history">Show History</button>');
                var save_history = $('<button id="save_history">Save History</button>');

                show_history.click(function(event) {
                  ajax_post('/show_history',null ,function(jsonData) {
                    $('#game_block').text(jsonData).show()
                  });
                });

                save_history.click(function(event) {
                  var name = prompt('Enter your name', 'name');
                  ajax_post('/save_history','name=' + name, function(jsonData) {
                    notice(jsonData);
                  });
                });

                $('#container').append(show_history).append(save_history);
              } else {
                notice(mark_guess(jsonData.result));
              }
            });
          });

          form.find('#guessField').after(guess);

          hint.click(function(event) {
            ajax_post('/hint',null , function(jsonData) {
               notice('HINT:' + jsonData);
            });
          });

          restart.click(function(event) {
              location.reload();
          });

          $('#container').append(form).append(hint).append(restart);
      }
    });
  });
});