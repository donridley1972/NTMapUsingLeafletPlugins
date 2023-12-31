/**Vertigo Tip by www.vertigo-project.com*/
this.vtip = function() {
    this.xOffset = -10; // x distance from mouse
    this.yOffset = 10; // y distance from mouse
    $("[title]").off('mouseenter.vtip mouseleave.vtip mousemove.vtip click.vtip').on('mouseenter.vtip',
        function(e) {
            this.t = this.title;
			if (this.t && this.nodeName != 'IFRAME'){
				this.title = '';
				this.top = (e.pageY + yOffset); this.left = (e.pageX + xOffset);
							this.t = this.t.replace(/\|/g,"\<br \/\>");
				$('body').append( '<p id="vtip"><img id="vtipArrow" />' + this.t + '</p>' );
				$('p#vtip #vtipArrow').attr("src", '/images/vtip_arrow.png');
				$('p#vtip').css("top", this.top+"px").css("left", this.left+"px").fadeIn("slow");
			}
        }
    ).on('mouseleave.vtip click.vtip',
        function() {
            this.title = this.t;
            $("p#vtip").fadeOut("slow").remove();
        }
    ).on('mousemove.vtip',
        function(e) {
            this.top = (e.pageY + yOffset);
            this.left = (e.pageX + xOffset);
            $("p#vtip").css("top", this.top+"px").css("left", this.left+"px");
        }
    );
};
$(document).ready(
  function($){
    vtip();
	$(document).ajaxComplete(function() {vtip()});
  }
);
