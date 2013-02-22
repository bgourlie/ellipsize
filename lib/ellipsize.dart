// Copyright (c) 2013, W. Brian Gourlie
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. All advertising materials mentioning features or use of this software
//    must display the following acknowledgement:
//    This product includes software developed by W. Brian Gourlie.
// 
// THIS SOFTWARE IS PROVIDED BY W. BRIAN GOURLIE ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL W. BRIAN GOURLIE BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

library ellipsize;
import 'dart:html';

/**
 * Truncate and append an ellipsis (…) to text that overflows the specified container.
 * It first checks to see if the overflow attribute of the container is set
 * to 'hidden' and if not, no truncation takes place.
 * 
 * It should also be noted that this only works for multiline text.  If you need
 * auto-ellisis functionality for single-line text, you should use CSS:
 * 
 *    text-overflow: ellipsis;
 *
 */
void ellipsize(Element el){  
  
  final tempElement = el.clone(true);
  if(el.getComputedStyle().overflow == 'hidden'){    
    tempElement.style.position = 'absolute';
    tempElement.style.overflow = 'visible';
    tempElement.style.width = '${el.clientWidth}px';
    tempElement.style.height = 'auto';
    tempElement.style.maxHeight = 'none';
    el.insertAdjacentElement('afterEnd', tempElement);
    
    final desiredHeight = el.clientHeight;
    
    //no truncating required
    if(tempElement.clientHeight == el.clientHeight) {
      el.style.border = '3px solid green';
      return;
    }
    
    final elToTruncate = _determineElementToTruncate(tempElement, tempElement.children, desiredHeight);
        
    var curText = elToTruncate.text.trim();
    
    while(curText.length > 0){                   
      final nextCutoff = elToTruncate.text.lastIndexOf(' ');
      
      if(nextCutoff == -1){
        el.remove();
        return;
      }
      
      final nextCutoffText = elToTruncate.text.substring(0, nextCutoff);
      curText = '${nextCutoffText}…';
      elToTruncate.text = curText;
      el.innerHtml = tempElement.innerHtml;
      
      if(tempElement.clientHeight <= desiredHeight){
        tempElement.remove();
        return;
      }
    }

    tempElement.remove();
  }
}

/**
 * Recursively determine the element in which truncating the text will satisfy the parent's size requirement 
 */
Element _determineElementToTruncate(Element rootContainer, List<Element> elements, int desiredHeight){
  final parent = elements[0].parent;
  for(int i = elements.length - 1; i >= 0; --i){
    final e = elements[i];
    e.remove();
    if(rootContainer.clientHeight <= desiredHeight){
      parent.children.add(e);
      
      if(elements[i].children.length == 0){
        //there are no child element -- return it so we can start truncating text
        return e;
      }else{
        //the element has child elements -- recurse
        return _determineElementToTruncate(rootContainer, e.children, desiredHeight);
      }
    }
  }
}

int _binarySearch(int length, int func(int val)){
  int low = 0;
  int high = length - 1;
  int best = -1;
  int mid;
  
  while(low <= high){
    mid = (low + high) ~/ 2;
    final result = func(mid);
    if(result < 0){
      high = mid - 1;
    } else if (result > 0){
      low = mid + 1;
    }else{
      best = mid;
      low = mid + 1;
    }
  }
  return best;
}
