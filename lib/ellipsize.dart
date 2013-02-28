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
class Ellipsize{
  
  static final _trimEnd = new RegExp(r'''(?:[\.!?\s,])*$''', multiLine: true, caseSensitive: false);
  
  final Element _el;
  final int _desiredHeight;
  final Element _tempElement;
  
  Node _nodeToTruncate;
  String _origText;
  
  Ellipsize(Element el) : 
    this._el = el,
    _desiredHeight = el.clientHeight,
    _tempElement = el.clone(true){

    if(el.getComputedStyle().overflow != 'hidden') return;   
      _tempElement.style.position = 'fixed';
      _tempElement.style.visibility = 'hidden';
      _tempElement.style.overflow = 'visible';
      _tempElement.style.width = '${el.clientWidth}px';
      _tempElement.style.height = 'auto';
      _tempElement.style.maxHeight = 'none';
      el.insertAdjacentElement('afterEnd', _tempElement);
      
      //no truncating required
      if(_tempElement.clientHeight <= _desiredHeight) {
        _tempElement.remove();
        return;
      }
            
      _nodeToTruncate = _tempElement.children.length == 0 
          ? _tempElement.nodes[0] 
          : _determineNodeToTruncate(_tempElement, _tempElement.children, _desiredHeight);
      
      if(_nodeToTruncate == null){
        //Bail out, we couldn't figure it out.  Fail.
        print('Ellipsizer: Unable to determine which node to truncate.');
        _tempElement.remove();
        return;
      }
               
      _origText = _nodeToTruncate.text;
      int len = _binarySearch(_origText.length - 1, _truncateText);
      
      if(len == -1){
        var parent = _nodeToTruncate.parent;
        _nodeToTruncate.remove();
        if(parent != null && parent.children.length == 0 && parent.text.trim().isEmpty){
          //the element is empty.  append the ellipses to the previous node's
          //text
          var index = parent.parent.children.indexOf(parent);
          if(parent.previousElementSibling != null){
            var prevSibling = parent.previousElementSibling;
            prevSibling.text = '${prevSibling.text.replaceAll(_trimEnd, '')}…'; 
            parent.remove();
          }
        }
      }else{
        _setEllipsis(len);
      }
      _el.innerHtml = _tempElement.innerHtml;
      _tempElement.remove();
  }
  
  int _truncateText(int i){
    _setEllipsis(i);
    return _tempElement.clientHeight >  _desiredHeight ? -1 : 0;
  }
  
  void _setEllipsis(int i){
    var newText = _origText.substring(0, i).replaceAll(_trimEnd, '');
    final textWithEllipses = '${newText}…';
    _nodeToTruncate.text = textWithEllipses;
  }
  
  /**
   * Recursively determine the element in which truncating the text will 
   * satisfy the parent's size requirement 
   */
  static Node _determineNodeToTruncate(Element rootContainer, List<Node> nodes, int desiredHeight){
    final parent = nodes[0].parent;
    for(int i = nodes.length - 1; i >= 0; --i){
      final curNode = nodes[i];
      curNode.remove();
      //it's an empty node (<br> for example), continue
      if(curNode.text.trim().isEmpty || (curNode.nodeType == 1 
          && curNode.nodes.length == 0)) continue;
      
      if(rootContainer.clientHeight <= desiredHeight){    
                
        parent.nodes.add(curNode);    
        
        //if it's an element with only a text node, return the text node
        if(curNode.nodeType == 1 && curNode.nodes.length == 1 
            && curNode.nodes[0].nodeType == 3){
          return curNode.nodes[0];
        }
        
        if(curNode.nodeType == 3){
          //it is a text element -- return it so we can start truncating text
          return curNode;
        }else{
          //the element has child elements -- recurse
          return _determineNodeToTruncate(rootContainer, curNode.nodes, desiredHeight);
        }
      }
    }
  }

  static int _binarySearch(int length, int func(int val)){
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
}
