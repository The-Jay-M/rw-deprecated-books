//
//  MyContactListener.h
//  Breakout
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct MyContact
{
	b2Fixture *fixtureA;
	b2Fixture *fixtureB;

	bool operator==(const MyContact& other) const
	{
		return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
	}
};

class MyContactListener : public b2ContactListener
{
public:
	std::vector<MyContact> _contacts;

	MyContactListener();
	~MyContactListener();

	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);    
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
};
