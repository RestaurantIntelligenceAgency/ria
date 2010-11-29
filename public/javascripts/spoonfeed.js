var already_equalized = false;

$('#jumbotron').cycle({
	fx: 'scrollHorz',
	timeout: 8000,
	easing: 'easeInOutCubic',
	pager: '#jumbotron_controller nav',
	pagerBuilder: jumbotronController
});

$('.hp_promo, .chapter, .topic').equalHeights();


// == Inbox for RIA messages
$(".inbox_message .readit").live('click', function(){
  var $message = $(this).parents('.inbox_message');
  $.post(this.href, "_method=put", function(){
    $message.fadeOut(300, function(){
      $message.remove();
    });
  },null);  
  return false;
});

$('.direct_message .readit').click(function(){
  var $message = $(this).parents('.direct_message');
  var messageId = $message.attr('id').match(/\d+$/g);
  $.post("/direct_messages/" + messageId + "/read", "_method=put", function(){
    $message.fadeOut(300, function(){
      $message.remove();
    });
  },null);  
  return false;
});

$('#profile_user_attributes_prefers_publish_profile').live('click',function(){
	if(!$(this).is(':checked')){
		return;
	}
	answer = confirm('Are you sure? Is your profile filled out yet?\n\nMake sure your profile is filled out a good amount before sharing it with the public!');
	if (answer){
		$(this).attr('checked','checked');
	}	else{
		$(this).removeAttr('checked');
	}
})


$('#profile-tabs').tabs({
	panelTemplate: '<section></section>',
	fx: { duration: 'fast', opacity: 'toggle' },
	show: function(event, ui) { 
		if(ui.panel.id == 'profile-extended' && !already_equalized){
			already_equalized = true;
			$('.culinary_job').equalHeights();
			$('.nonculinary_job').equalHeights();
			$('.award').equalHeights();
			$('.accolade').equalHeights();
			$('.enrollment').equalHeights();
			$('.competition').equalHeights();
			$('.internship').equalHeights();
			$('.stage').equalHeights();
			$('.apprenticeship').equalHeights();
			$('.cookbook').equalHeights(); 
		}
	}
});

$('.tabable').tabs({
	panelTemplate: '<section></section>',
	fx: { duration: 'fast', opacity: 'toggle' }
});


if (window.current_user_id) {
  var $hideHelpBox = $('<div id="hide_help_box"/>');
  $("#get_started").append($hideHelpBox);
  $hideHelpBox.click(function(){
    $.post("/users/" + window.current_user_id, {
        _method: 'put',
        'user[preferred_hide_help_box]': '1'
      }, function(data){
         $hideHelpBox.parent().fadeOut();
      }, "js"
    );
  });
}


height = $('#btl_game').height();
$('#btl_game').height(height);

$('.new_question').live('click', function(){
	$('#btl_game_content').fadeOut();
	$(this).css({
		backgroundRepeat: 'no-repeat',
		backgroundPosition: 'center center',
		backgroundImage: 'url(/images/redesign/ajax-loader.gif)'
	});
	$.ajax({
		data:'authenticity_token=' + encodeURIComponent($(this).attr('data-auth')),
	 	success:function(request){
			$('#btl_game_content').html(request).fadeIn();
			$('.new_question').css({
				backgroundImage: 'url(/images/redesign/icon-refresh.png)',
				backgroundPosition: '0 0'
			})
		},
		type:'post', 
		url:'/users/'+$(this).attr('data-user-id')+'/questions/refresh'
	}); 
	return false;
})
$('#profile_answer_submit').live('click', function(){
	$(this).val('posting...').attr('disabled','disabled');
})
$('#new_quick_reply button').live('click', function(){
	$(this).text('posting...').attr('disabled','disabled');
});

function jumbotronController(idx, elem){
	idx++;
	return html+='<a href="#">'+idx+'</a>';
}


var colorboxOnComplete = function(){
  $('#culinary_job_chef_is_me').click(function(){
    var nameField = $('#culinary_job_chef_name');
    var $this     = $(this);
    if ($this.is(":checked")) {
      nameField.val($(this).attr('rel'));
    } else {
      nameField.val('');
    }
  });
};

$('#criteria_accordion').accordion({
	autoHeight: false,
	collapsible: true,
	active: false,
	header: '.accordion_box a',
	change: function() {
		$('.accordion_box').each(function(){
			if($(this).find('input:checked').length > 0){
				$(this).find('a').addClass('options_selected');
			} else {
				$(this).find('a').removeClass('options_selected');
			}
		});
	}
}).find('.loading').removeClass('loading');

$(document).ready(function(){
	var bindAjaxDeleters = function(){
	  $('a.delete').ajaxDestroyLink({
	    containerSelector: 'li:first'
	  });
	};
	
	bindAjaxDeleters();
	
	
	
	var bindColorbox = function() {
	  $('.colorbox').colorbox({
	      initialWidth: 450,
	      onComplete: colorboxOnComplete,
	      onClosed: function() {
	        bindAjaxDeleters();
	        bindColorbox();
	      }
	  });
	};

  function close_box(){
    $.fn.colorbox.close();
  }

  $('.close').live('click', close_box);

  function post_reply_text(){
    $('#new_quick_reply button').text('Post Reply');
  }

  // Do it!
  bindColorbox();

	$('#colorbox form.stage, #colorbox form.apprenticeship, #colorbox form.nonculinary_enrollment, #colorbox form.award, #colorbox form.culinary_job, #colorbox form.nonculinary_job, #colorbox form.accolade, #colorbox form.enrollment, #colorbox form.competition, #colorbox form.internship').live('submit', colorboxForm);
	$("a.showit").showy();
});

$.fn.ajaxDestroyLink = function(options){
  var config = {
    confirmMessage: "Are you sure you want to PERMANENTLY delete this?",
    containerSelector: 'tr:first'
  };
  
  if(options) $.extend(config, options);
  
  return this.each(function(){
    var $this = $(this);
    $this.removeAttr('onclick');
    $this.unbind();
    $this.click(function(){
      if (confirm(config.confirmMessage)) {
        $.post(this.href+".js", {_method: 'delete'}, function(data, status){
          var container = $this.parents(config.containerSelector);
          container.fadeOut(200,function(){
            container.remove();
          });
        });
      }
      return false;
    });
  });
};

var colorboxForm = function(){
  var $form = $(this);
  // var button = $form.find('button:first');
  // button.disable();
  $form.ajaxSubmit({
    dataType: 'json',
    url: $form.attr('action') + '.json',
    success: function(text){
      var $html = $(text.html);
      var $id   = $html.attr('id');
      var singularName = $id.replace(/^new_/, "").replace(/_\d+$/, "");
      var existingElement = $('#'+ $id);
      if (existingElement.length) {
        existingElement.html($html.html());
      } else {
        $("#" + singularName + "s").append($html);
      }
      $.fn.colorbox.close();
    },
    error: function(xhr, status){
      var response;
      try { response = $(xhr.responseText); } catch(e) { response = xhr.responseText; }
      $.colorbox({html: response});
    }
  });
  // button.enable();

  return false;
};


// == Dynamic Updates for Employment Searching
var	$employmentsList  = $("#employment_list");
var $employmentInputs = $("#employment_criteria input[type=checkbox]");
var $loaderImg =        $('<img class="loader" src="/images/ajax-loader.gif" />').hide();

// load the image load indicator, hidden
$employmentsList.before($loaderImg);

function updateEmploymentsList() {
	input_string = $employmentInputs.serialize();
	$loaderImg.show();
	$employmentsList.hide();
	$employmentsList.load('/employment_search', input_string, function(responseText, textStatus){
	  $loaderImg.hide();
	  $employmentsList.fadeIn(300);
	});
	// return true;	
}

$employmentInputs.change(updateEmploymentsList);

// Directory search
var	$directoryList  = $("#directory_list");
var $directoryInputs = $("#directory_search #employment_criteria input[type=checkbox]");

$directoryList.before($loaderImg);

function updateDirectoryList() {
	input_string = $directoryInputs.serialize();
	$loaderImg.show();
	$directoryList.hide();
	$directoryList.load('/directory/search', input_string, function(responseText, textStatus){
	  $loaderImg.hide();
	  $directoryList.fadeIn(300);
	});
	// return true;	
}

$directoryInputs.change(updateDirectoryList);

