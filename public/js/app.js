$( document ).ready(function() {
  function notice(message) {
    var noticeDiv = $('<div class="notice"><p class="notice-message">'+message+'</p></div>');
    $('.notice-block').append(noticeDiv.fadeIn(500).delay(5000).fadeOut(500));
  };

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
          var form = $('  <form id="main-form">\
                          <input type="text" name="text" class="form-control" id="guessField" placeholder="Make Guess">\
                        </form>');
          var hint  = $('<button type="button" class="btn btn-info" id="hint">Hint</button>');
          var restart = $('<button type="button" class="btn btn-warning" id="restart">Restart</button>');

          guess = $('<button type="button" class="btn btn-primary" id="guess" value="guess!">Guess</button>');

          guess.click(function(event) {
            ajax_post('/guess','guess=' + $('#guessField').val(), function(jsonData) {
              console.log(jsonData);
              if (jsonData.status == 'invalid_input') {
                notice(jsonData.text);
              } else if (jsonData.status == 'game_over') {
                notice(jsonData.text);
                $('#main-form').hide();
                $('#hint').hide();

                $('#game_block').text('History').show()
               
                $.each( jsonData.history, function( key, value ) {
                  $('#game_block').append('<p>'+value+'</p>');
                });
                $('#game_block').css('padding','0 30% 0 35%');

                var show_history = $('<button type="button" class="btn btn-info" id="show_history">Show History</button>');
                var save_history = $('<button type="button" class="btn btn-info" id="save_history">Save History</button>');

                show_history.click(function(event) {
                  ajax_post('/show_history',null ,function(jsonData) {
                    $('#show_history').hide();

                    table = $('<table class="table table-striped">\
                              <thead>\
                                <tr>\
                                  <th>#</th>\
                                  <th>date</th>\
                                  <th>user</th>\
                                  <th>status</th>\
                                  <th>attempts</th>\
                                </tr>\
                              </thead>\
                              <tbody>\
                              </tbody>\
                              </table>')
                    $('#container').append(table);

                  $.each( jsonData, function( key, value ) {
                    row = $(' <tr class="active">\
                                <th scope="row">'+key+'</th>\
                                <td>'+value[0].date+'</td>\
                                <td>'+value[0].user+'</td>\
                                <td>'+value[0].status+'</td>\
                                <td>'+value[0].attempts+'</td>\
                              </tr>');
                    $('.table > tbody').append(row);
                  });

                  });
                });

                save_history.click(function(event) {
                  $('#save_history').hide();
                  var name = prompt('Enter your name', 'name');
                  ajax_post('/save_history','name=' + name, function(jsonData) {
                    notice(jsonData);
                  });
                });

                $('#container').append(show_history).append(save_history);
                $(".btn").css("width", "23%");
                $(".btn").css("margin", "0 5% 0 5%");
              } else {
                if (jsonData.result.length > 0) {
                  notice('Result: ' + jsonData.result + '<br>' +' Attempts left: ' + jsonData.turns);
                } else {
                  notice('No matches Attempts left: ' + jsonData.turns);
                }
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