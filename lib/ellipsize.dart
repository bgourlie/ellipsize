/**
Copyright (c) 2013, W. Brian Gourlie
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed by W. Brian Gourlie.

THIS SOFTWARE IS PROVIDED BY W. BRIAN GOURLIE ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL W. BRIAN GOURLIE BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
    final allNodes = new List<Node>();
    
    for(final node in tempElement.nodes){
      _addAllNodes(node, allNodes);
    }

    while(tempElement.clientHeight > desiredHeight){
      for(int i = allNodes.length - 1; i >=0; i--){
        final curNode = allNodes[i];
        
        if(curNode.text.trim().isEmpty){
          curNode.remove();
          continue;
        }
        
        var curText = curNode.text.trim();
        
        while(curText.length > 0){                   
          final nextCutoff = curNode.text.lastIndexOf(' ');
          
          if(nextCutoff == -1){
            curNode.remove();
            break;
          }
          
          final nextCutoffText = curNode.text.substring(0, nextCutoff);
          curText = '${nextCutoffText}…';
          curNode.text = curText;
          el.innerHtml = tempElement.innerHtml;
          
          if(tempElement.clientHeight <= desiredHeight){
            tempElement.remove();
            return;
          }
        }
      }
    }
    tempElement.remove();
  }
}

void _addAllNodes(Node curNode, List<Node> nodes){
  nodes.add(curNode);
  for(final node in curNode.nodes){
    _addAllNodes(node, nodes);
  }
}
