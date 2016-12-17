# HideAncestry
This gem allows hide and restore nodes of [ancestry gem](https://github.com/stefankroes/ancestry)

### Usage
State before hiding
```
$ User.first.subtree
$ #<ActiveRecord::Relation [
    <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil>,
      <id: 2, name: 'Parent', hided_status: false, ancestry: '1'>,
        <id: 3, name: 'Child', hided_status: false, ancestry: '1/2'> ]>
```

Hiding second user
```
$ User.second.hide
```

Ancestry subtree became changed
```
$ User.first.subtree
$ #<ActiveRecord::Relation [
    <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil>,
      <id: 3, name: 'Child', hided_status: false, ancestry: '1'> ]>

User.hided
$ <ActiveRecord::Relation [
    <id: 2, name: 'Parent', hided_status: true, ancestry: nil> ]>
```

Restoring hided user
```
$ User.find(2).restore # restore hided user to previous subtree

$ User.first.subtree
$ #<ActiveRecord::Relation [
    <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil>,
      <id: 2, name: 'Parent', hided_status: false, ancestry: '1'>,
        <id: 3, name: 'Child', hided_status: false, ancestry: '1/2'> ]>

User.hided
$ #<ActiveRecord::Relation []>
```
### Installation
Add to your Gemfile
``` ruby
gem 'ancestry'
gem 'hide_ancestry'
```
And install
```
bundle install
```

To install hide_ancestry migration:
```ruby
 # Set any table with ancestry
 # Type --no-hided-status if you will use your own boolean column to hide nodes
rails generate hide_ancestry_migration users [--no-hided-status]
rake db:migrate
```
It will add to the specified table:
+ old_parent_id:integer
+ old_child_ids:array  (using rails serialize)
+ hide_ancestry:string
+ hided_status:boolean

Add to your model
```ruby
class User < ActiveRecord::Base
  has_ancestry
  has_hide_ancestry
end
```

###Instance methods
```ruby
hide                      # hide node:
                          #   node#ancestry became nil;
                          #   node#hided_status became true
restore                   # restore node:
                          #   restore node#ancestry
                          #   node#hided_status became false
                          #   update node old descendants

hided?                    # check if node is hided
hided_parent_changed?     # check if node changed it parent
hided_children_present?   # check if node has hided children

children_of_hided         # return children of hided node
hided_parent              # return hided parent of node if present
subtree_with_hided        # return subtree with hided nodes
hided_descendants_ids     # return ids of hided users in subtree 
hided_path_ids            # old ancestors ids of hided node

```

###Scopes
```ruby
hided            # return nodes with hided_status
unhided          # return nodes without hided_status
hided_nodes(ids) # return hided nodes with ids
hided_childs(id) # return hided nodes which was children of node#id

```

###Options for has_hide_ancestry
```ruby
# You can remove hide_status col if you use this option
use_column: :you_custom_bool_column 

# Unlock readable_depth method;
# when depth == 3, readable_depth == '1.2.3'
readable_depth: true
```

###Some notes
+ You can change ancestry subtree as you want after node became hided. Hided node still can be restored to previous parent and will update it old descendants (if descendant did not change it parent)
+ Hided nodes have no actual ancestry - no any ancestry parents or descendants