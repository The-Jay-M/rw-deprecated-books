//
//  MyContactListener.m
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

#import "MyContactListener.h"

MyContactListener::MyContactListener() : _contacts()
{
}

MyContactListener::~MyContactListener()
{
}

void MyContactListener::BeginContact(b2Contact *contact)
{
	// We need to copy out the data because the b2Contact passed in
	// is reused.
	MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
	_contacts.push_back(myContact);
}

void MyContactListener::EndContact(b2Contact *contact)
{
	MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };

	std::vector<MyContact>::iterator pos = std::find(_contacts.begin(), _contacts.end(), myContact);
	if (pos != _contacts.end())
	{
		_contacts.erase(pos);
	}
}

void MyContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold)
{
}

void MyContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse)
{
}
