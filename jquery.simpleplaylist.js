
var currentSong;
var shudPlay;
var timer;
var isWaitingForNextTrack="NO";
 function refreshLoop() {
     if(timer)
     clearTimeout(timer);
    var auda = $('#jukebox .aud').get(0);
	var URL = "/check//"+!auda.paused;
	$.ajax({
           url: URL,
           cache: false
           }).done(function(data) {
                   var aud2 = $('#jukebox .aud').get(0);
                 if(isWaitingForNextTrack=="YES")
                   return;
                 
                   if( (currentSong !=data)&&data.length>0&&data!="PAUSED") {
                   currentSong=data;
                   playSong(data);
                   shudPlay="YES";
                   return;
                   
                                      }

                   if(data=="PAUSED")
                   {
                   shudPlay="NO";

                   togglePause();
                   
                   timer=window.setTimeout(function() {
                              refreshLoop();
                              }, 1000);
                   return;

                   }
                   if((currentSong==data) && aud2.paused && shudPlay=="NO"&&data.length>0 )
                   {
                   shudPlay="YES";

                   togglePlay();
 
                   timer=window.setTimeout(function() {
                              refreshLoop();
                              }, 1000);
                   return;

                   }
                   
                   else
                                  
                   timer=window.setTimeout(function() {
                                     refreshLoop();
                                     }, 1000);
                   

                   }).fail(function() {
                          timer= window.setTimeout(function() {
                                             refreshLoop();
                                             }, 1000);
                          
                           });
 
    
    }

 function playSong(song) {
    
    var aud = $('#jukebox .aud').get(0);
 
     aud.setAttribute('src', "/music//" + song );
    aud.load();
     if(aud.paused){
         $('#jukebox .play').trigger('click');
     }
     else {aud.play();
         
     }


     songInfo();
  

}
function load(){
    var aud = $('#jukebox .aud').get(0);
     aud.addEventListener('progress', function(evt) {
                         var width = parseInt($('#jukebox .loader').css('width'));
                         var percentLoaded = Math.round(evt.loaded / evt.total * 100);
                         var barWidth = Math.ceil(percentLoaded * (width / 100));
                         $('#jukebox .load-progress').css( 'width', barWidth );
                         
                         });
    
    aud.addEventListener('timeupdate', function(evt) {
                         var width = parseInt($('#jukebox .loader').css('width'));
                         var percentPlayed = Math.round(aud.currentTime / aud.duration * 100);
                         var barWidth = Math.ceil(percentPlayed * (width / 100));
                         $('#jukebox .play-progress').animate({width:barWidth}, 1);
                         });
    aud.addEventListener('canplay', function(evt) {
                         if(aud.paused){
                         $('#jukebox .play').trigger('click');
                         }
                         else {aud.play();
 
                         }
                         });
    
    aud.addEventListener('ended', function(evt) {
                         isWaitingForNextTrack="YES";
                         if(timer)
                         clearTimeout(timer);

                         next();
                         });
    $('#jukebox .loader').bind('click', function(evt) {
                               
                               aud.pause();
                               if (aud.duration != 0) {
                               
                               
                               left = $('#jukebox .loader').offset().left;
                               offset = evt.pageX - left;
                               percent = offset / $('#jukebox .loader').width();
                               duration_seek = percent * aud.duration;
                               aud.currentTime = duration_seek;
                               
                               
                               }
                               aud.play();
                               });

    $('#jukebox .play').bind('click', function(evt) {
                              evt.preventDefault();
                             if (aud.paused) {
                                                           aud.play();
                             
                             
                             
                             $('#jukebox .play').css( 'background-position', '-30px top');
                             }
                             
                             else {aud.pause();
                              $('#jukebox .play').css( 'background-position', 'left top');
                             }
                             });
    
    
    
    $('#jukebox .next').bind('click', function(evt) {
                             next();
                             });
    
    $('#jukebox .prev').bind('click', function(evt) {
                             prev();
                             });



}
function artwork(){
    
    var URL = "/get_artwork";
	$.ajax({
           url: URL,
           cache: false
           }).done(function(data) {
                    document.images['artwork-image'].src=data;
                   refreshLoop();
  
                   
                   }).fail(function() {
                           
                           refreshLoop();

                           
                           });

    
}
function songInfo(){
    var URL = "/get_song_info";
	$.ajax({
           url: URL,
           cache: false
           }).done(function(data) {
                   $('#jukebox .info').html(data);
                   
                   artwork();

                   
                   }).fail(function() {
                            });


}
function next(){
    var URL = "/next_song";
	$.ajax({
           url: URL,
           cache: false
           }).done(function(data) {
                   
                   isWaitingForNextTrack="NO";
                   refreshLoop();
                    }).fail(function() {
                            
                            
                            if(timer)
                            clearTimeout(timer);
                            
                            timer=window.setTimeout(function() {
                                              next();
                                              }, 1000);

                            
                            
                            });



}

function prev(){
    
    var URL = "/prev_song";
	$.ajax({
           url: URL,
           cache: false
           }).done(function(data) {
                   }).fail(function() {
                            });
    
    
    
}
function togglePlay(){
    var aud = $('#jukebox .aud').get(0);

    if (aud.paused) {
        aud.play();
        
        
        
        $('#jukebox .play').css( 'background-position', '-30px top');
    }
    
    


}

function togglePause(){
    var aud = $('#jukebox .aud').get(0);
 
    if (!aud.paused) {
        aud.pause();
        
        
        
 $('#jukebox .play').css( 'background-position', 'left top');
    
    }



}
function verify(){
	var URL = "/verify";
	$.ajax({
           url: URL,
           cache: false
           }).done(function(data) {
    if(data.length>0&&data=="Denied"){
        
        alert("The host device is already streaming . ");
        
        return;
    }
                   
                   if(data.length>0&&data=="Accept"){
                   
                   refreshLoop();

                   
                   
                   }
                   }).fail(function() {
                           
                           
                           });
    

}
$(document).ready(function() {
                   load();
                  verify();
                  });